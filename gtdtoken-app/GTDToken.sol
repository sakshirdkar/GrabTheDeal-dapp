pragma solidity ^0.5.17;

// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
//
// ----------------------------------------------------------------------------
contract ERC20Interface {
    function totalSupply() internal view returns (uint);
    function balanceOf(address tokenOwner) public view returns (uint balance);
    function allowance(address tokenOwner, address spender) internal view returns (uint remaining);
    function transfer(address to, uint tokens) internal returns (bool success);
    function approve(address spender, uint tokens) internal returns (bool success);
    function transferFrom(address from, address to, uint tokens) internal returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

// ----------------------------------------------------------------------------
// Safe Math Library
// ----------------------------------------------------------------------------
contract SafeMath {
    function safeAdd(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function safeSub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a); c = a - b; } 
    function safeMul(uint a, uint b) internal pure returns (uint c) {
        c = a * b; 
        require(a == 0 || c / a == b); 
        
    } 
    function safeDiv(uint a, uint b) internal pure returns (uint c) { 
        require(b > 0);
        c = a / b;
    }
}


contract  GTDToken is ERC20Interface, SafeMath {
    string public name;
    string public symbol;
    uint8 internal decimals;
    address payable owner;
    uint256 internal _totalSupply;
    a
    // queue
    mapping(uint256 => address) queue;
    uint256  internal first=1;
    uint256 internal last=0;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;
    
    function enqueue(address data) internal {
        last += 1;
        queue[last] = data;
    }

    function dequeue() internal returns (address) {
        require(last >= first);  // non-empty queue

        address customerAdd = queue[first];

        delete queue[first];
        first += 1;
        return customerAdd;
    }
    function getQueueLength() public view returns (uint){
        return last-first+1;
    }
    
    
    /**
     * Constructor function
     *
     * Initializes contract with initial supply tokens to the creator of the contract
     */
    constructor() public {
        name = "GTDToken";
        symbol = "GTD";
        decimals = 0;
        _totalSupply = 100;
        owner = msg.sender;
        balances[owner] = _totalSupply;
        emit Transfer(address(0), owner, _totalSupply);
    }
    
    // modifiers -3
    modifier onlyOwner(){
            require(msg.sender == owner);
            _;
        }
    modifier checkBalance(){
            require(msg.sender.balance > msg.value);
            _;
        }
    modifier checkStockAvailability(){
            require(balanceOf(owner) >= getQueueLength());
            _;
        }
        
    //ERC20 Token methods
    function totalSupply() internal view returns (uint) {
        return _totalSupply -  balances[owner];
    }
    
    function productsSold() public view returns (uint) {
        return _totalSupply -  balances[owner];
    }

    function balanceOf(address tokenOwner) public view returns (uint balance) {
        return balances[tokenOwner];
    }

    function allowance(address tokenOwner, address spender) internal view returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }

    function approve(address spender, uint tokens) internal returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }

    function transfer(address to, uint tokens) internal returns (bool success) {
        balances[owner] = safeSub(balances[owner], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        emit Transfer(owner, to, tokens);
        return true;
    }

    function transferFrom(address from, address to, uint tokens) internal returns (bool success) {
        balances[from] = safeSub(balances[from], tokens);
        allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        emit Transfer(from, to, tokens);
        return true;
    }
    //Smart Contract methods - 4
    function expressInterest() public checkBalance payable{
        enqueue(msg.sender);
        payForToken();
    }
     
    function payForToken() internal{
         owner.transfer(msg.value);
    }
    
    function getOwner() public view returns (address){
       return owner;
    }
    
    function initiateSelling() public onlyOwner checkStockAvailability {
        uint len = getQueueLength() > balances[owner]?  balances[owner]: getQueueLength();
        for(uint i = 0;i<len;i++){
            address top_customer_address =  dequeue();
            transfer(top_customer_address,1);
        }
    }
   
    
    function addNewStock(uint  tokens) public onlyOwner{
        balances[owner]+=tokens;
        _totalSupply+=tokens;
    }
    
}