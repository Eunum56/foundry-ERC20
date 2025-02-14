// Layout of Contract:
// version
// imports
// errors
// interfaces, libraries, contracts
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions

// SPDX-License-Identifier:MIT

pragma solidity ^0.8.24;

contract MyToken {
    // ERRORS
    error MyToken__NotOwner();
    error MyToken__MaxSupplyExceeds();
    error MyToken__NotEnoughTokens();
    error MyToken__InvalidAddress();
    error MyToken__AllowanceExceeds();
    error MyToken__NotEnoughAllowance();

    // STATE_VARIABLES
    string private s_name;
    string private s_symbol;
    uint8 private immutable i_decimals;
    uint256 private constant MAX_SUPPLY = 1_000_000 * 10 ** 18;
    uint256 private s_totalSupply;
    address private immutable i_owner;

    mapping(address => uint256) private s_balances;
    mapping(address => mapping(address => uint256)) private s_allowed;

    // EVENTS
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );

    // MODIFIER
    modifier onlyOwner() {
        require(msg.sender == i_owner, MyToken__NotOwner());
        _;
    }

    // FUNCTIONS
    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _initialSupply
    ) {
        require(_initialSupply <= MAX_SUPPLY, MyToken__MaxSupplyExceeds());
        s_name = _name;
        s_symbol = _symbol;
        i_decimals = _decimals;
        s_totalSupply = _initialSupply;
        i_owner = msg.sender;
        s_balances[msg.sender] = _initialSupply;
        emit Transfer(address(0), msg.sender, _initialSupply);
    }

    function mint(address _minter, uint256 _value) external onlyOwner {
        require(
            _value + s_totalSupply <= MAX_SUPPLY,
            MyToken__MaxSupplyExceeds()
        );
        require(_minter != address(0), MyToken__InvalidAddress());
        s_balances[_minter] += _value;
        s_totalSupply += _value;
        emit Transfer(address(0), _minter, _value);
    }

    function burn(uint256 _value) public {
        require(s_balances[msg.sender] >= _value, MyToken__NotEnoughTokens());
        s_balances[msg.sender] -= _value;
        s_totalSupply -= _value;
        emit Transfer(msg.sender, address(0), _value);
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        require(s_balances[msg.sender] >= _value, MyToken__NotEnoughTokens());
        require(_to != address(0), MyToken__InvalidAddress());
        s_balances[msg.sender] -= _value;
        s_balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool) {
        require(_spender != address(0), MyToken__InvalidAddress());
        s_allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public returns (bool) {
        require(
            _from != address(0) && _to != address(0),
            MyToken__InvalidAddress()
        );
        uint256 remaningAllowance = s_allowed[_from][msg.sender];
        require(remaningAllowance >= _value, MyToken__AllowanceExceeds());
        require(s_balances[_from] >= _value, MyToken__NotEnoughTokens());
        s_balances[_from] -= _value;
        s_balances[_to] += _value;
        s_allowed[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    function increaseAllowance(
        address _spender,
        uint256 _value
    ) public returns (bool) {
        require(address(0) != _spender, MyToken__InvalidAddress());
        s_allowed[msg.sender][_spender] += _value;
        emit Approval(msg.sender, _spender, s_allowed[msg.sender][_spender]);
        return true;
    }

    function decreaseAllowance(
        address _spender,
        uint256 _value
    ) public returns (bool) {
        require(address(0) != _spender, MyToken__InvalidAddress());
        require(
            s_allowed[msg.sender][_spender] >= _value,
            MyToken__NotEnoughAllowance()
        );
        s_allowed[msg.sender][_spender] -= _value;
        emit Approval(msg.sender, _spender, s_allowed[msg.sender][_spender]);
        return true;
    }

    // GETTERS / VIEW OR PURE FUNCTIONS
    function name() external view returns (string memory) {
        return s_name;
    }

    function symbol() external view returns (string memory) {
        return s_symbol;
    }

    function decimals() external view returns (uint8) {
        return i_decimals;
    }

    function totalSupply() external view returns (uint256) {
        return s_totalSupply;
    }

    function balanceOf(address _owner) external view returns (uint256) {
        return s_balances[_owner];
    }

    function allowance(
        address _owner,
        address _spender
    ) public view returns (uint256) {
        return s_allowed[_owner][_spender];
    }

    function getOwner() external view returns (address) {
        return i_owner;
    }
}
