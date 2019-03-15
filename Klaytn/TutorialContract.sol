pragma solidity ^0.4.24;

// Made By Tom - tom@devtooth.com

library SafeMath
{
  	function mul(uint256 a, uint256 b) internal pure returns (uint256)
    {
		uint256 c = a * b;
		assert(a == 0 || c / a == b);

		return c;
  	}

  	function div(uint256 a, uint256 b) internal pure returns (uint256)
	{
		uint256 c = a / b;

		return c;
  	}

  	function sub(uint256 a, uint256 b) internal pure returns (uint256)
	{
        assert(b <= a);

		return a - b;
  	}

  	function add(uint256 a, uint256 b) internal pure returns (uint256)
	{
		uint256 c = a + b;
		assert(c >= a);

		return c;
  	}
}

contract ERC20Interface
{
    event Transfer( address indexed _from, address indexed _to, uint _value);
    event Approval( address indexed _owner, address indexed _spender, uint _value);
    
    function totalSupply() view public returns (uint _supply);
    function balanceOf( address _who ) public view returns (uint _value);
    function transfer( address _to, uint _value) public returns (bool _success);
    function approve( address _spender, uint _value ) public returns (bool _success);
    function allowance( address _owner, address _spender ) public view returns (uint _allowance);
    function transferFrom( address _from, address _to, uint _value) public returns (bool _success);
}

contract DevToothToken is ERC20Interface
{
    using SafeMath for uint;
    
    address public creator;
    string public name;
    uint public decimals;
    string public symbol;
    uint public totalTokenSupply;
    
    uint constant private E18 = 1000000000000000000;
    
    uint constant public maxTotalSupply     = 100000000 * E18;
    
    uint public issuedTokenCount;
    
    mapping (address => uint) public balances;
    mapping (address => mapping ( address => uint )) public approvals;
    
    event TokenIssue(address indexed _to, uint _tokens);
    
    constructor() public
    {
        name        = "DevTooth Token";
        decimals    = 18;
        symbol      = "DTT";
        
        totalTokenSupply = 0;
        creator = msg.sender;
    }
    
    // ERC - 20 Interface -----

    function totalSupply() view public returns (uint) 
    {
        return totalTokenSupply;
    }
    
    function balanceOf(address _who) view public returns (uint) 
    {
        return balances[_who];
    }
    
    function transfer(address _to, uint _value) public returns (bool) 
    {
        require(balances[msg.sender] >= _value);
        
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        
        emit Transfer(msg.sender, _to, _value);
        
        return true;
    }
    
    function approve(address _spender, uint _value) public returns (bool)
    {
        require(balances[msg.sender] >= _value);
        
        approvals[msg.sender][_spender] = _value;
        
        emit Approval(msg.sender, _spender, _value);
        
        return true; 
    }
    
    function allowance(address _owner, address _spender) view public returns (uint) 
    {
        return approvals[_owner][_spender];
    }

    function transferFrom(address _from, address _to, uint _value) public returns (bool) 
    {
        require(balances[_from] >= _value);
        require(approvals[_from][msg.sender] >= _value);
        
        approvals[_from][msg.sender] = approvals[_from][msg.sender].sub(_value);
        balances[_from] = balances[_from].sub(_value);
        balances[_to]  = balances[_to].add(_value);
        
        emit Transfer(_from, _to, _value);
        
        return true;
    }
    
    // Issue Function -----
    
    function tokenIssue(address _to, uint _value) public
    {
        require(msg.sender == creator);
        
        uint tokens = _value * E18;
        require(maxTotalSupply >= issuedTokenCount.add(tokens));
        
        balances[_to] = balances[_to].add(tokens);
        
        totalTokenSupply = totalTokenSupply.add(tokens);
        issuedTokenCount = issuedTokenCount.add(tokens);
        
        emit TokenIssue(_to, tokens);
    }
    
    // payable Function
    
    function () payable external
    {
        revert();
    }
    
    function withdrawTokens(address _contract, uint _decimals, uint _value) public
    {
        require(msg.sender == creator);
        
        if(_contract == address(0x0))
        {
            uint eth = _value.mul(10 ** _decimals);
            msg.sender.transfer(eth);
        }
        else
        {
            uint tokens = _value.mul(10 ** _decimals);
            ERC20Interface(_contract).transfer(msg.sender, tokens);
            
            emit Transfer(address(0x0), msg.sender, tokens);
        }
    }
    
    function close() public
    {
        require(msg.sender == creator);
    
        selfdestruct(msg.sender);
    }
}
