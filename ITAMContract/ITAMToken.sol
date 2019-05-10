pragma solidity ^0.5.8;

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

contract OwnerHelper
{
  	address public owner;

  	event ChangeOwner(address indexed _from, address indexed _to);

  	modifier onlyOwner
	{
		require(msg.sender == owner);
		_;
  	}
  	
  	constructor() public
	{
		owner = msg.sender;
  	}
  	
  	function transferOwnership(address _to) onlyOwner public
  	{
    	require(_to != owner);
    	require(_to != address(0x0));

        address from = owner;
      	owner = _to;
  	    
      	emit ChangeOwner(from, _to);
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

contract ITAMToken is ERC20Interface, OwnerHelper
{
    using SafeMath for uint;
    
    string public name;
    uint public decimals;
    string public symbol;
    
    uint constant private E18 = 1000000000000000000;
    uint constant private month = 2592000;
    
    // Total                                        2,500,000,000
    uint constant public maxTotalSupply =           2500000000 * E18;
    
    // Advisor & Early Supporters                   125,000,000 (5%)
    // - Vesting 3 month 2 times
    uint constant public maxAdvSptSupply =          125000000 * E18;
    
    // Team & Founder                               250,000,000 (10%)
    // - Vesting 6 month 3 times
    uint constant public maxTeamSupply =            250000000 * E18;
    
    // Marketing                                    375,000,000 (15%)
    // - Vesting 6 month 1 time
    uint constant public maxMktSupply =             375000000 * E18;
    
    // ITAM Ecosystem                               750,000,000 (30%)
    // - Vesting 3 month 1 time
    uint constant public maxEcoSupply =             750000000 * E18;
    
    // Sale Supply                                  1,000,000,000 (40%)
    uint constant public maxSaleSupply =            1000000000 * E18;
    
    // * Sale Details
    // Friends and Family                           130,000,000 (5.2%)
    // - Lock Monthly 20% 20% 20% 20% 20% 
    uint constant public maxFnFSaleSupply =         130000000 * E18;
    
    // Private Sale                                 345,000,000 (13.8%)
    // - Lock Monthly 20% 20% 20% 20% 10% 10%
    uint constant public maxPrivateSaleSupply =     345000000 * E18;
    
    // Public Sale                                  525,000,000 (19%)
    uint constant public maxPublicSaleSupply =      525000000 * E18;
    // *
    
    uint constant public advSptVestingDate = 3 * month;
    uint constant public advSptVestingTime = 2;
    
    uint constant public teamVestingDate = 6 * month;
    uint constant public teamVestingTime = 3;
    
    uint constant public mktVestingDate = 6 * month;
    uint constant public mktVestingTime = 1;
    
    uint constant public ecoVestingDate = 3 * month;
    uint constant public ecoVestingTime = 1;
    
    uint constant public fnfSaleLockDate = 1 * month;
    uint[5] constant public fnfSaleLockPer = [20, 20, 20, 20, 20];
    
    uint constant public privateSaleLockDate = 1 * month;
    uint[6] constant public privateSaleLockPer = [20, 20, 20, 20, 20, 10, 10];
    
    uint public totalTokenSupply;
    
    uint public tokenIssuedAdvSpt;
    uint public tokenIssuedTeam;
    uint public tokenIssuedMkt;
    uint public tokenIssuedEco;
    
    uint public tokenIssuedSale;
    uint public fnfIssuedSale;
    uint public privateIssuedSale;
    uint public publicIssuedSale;
    
    uint public burnTokenSupply;
    
    mapping (address => uint) public balances;
    mapping (address => mapping ( address => uint )) public approvals;
    mapping (address => bool) public blackLists;
    
    mapping (address => uint) public advSptVestingTimer;
    mapping (address => mapping ( uint => uint )) public advSptVestingWallet;
    
    mapping (address => uint) public teamVestingTimer;
    mapping (address => mapping ( uint => uint )) public teamVestingWallet;
    
    mapping (address => uint) public mktVestingTimer;
    mapping (address => mapping ( uint => uint )) public mktVestingWallet;
    
    mapping (address => uint) public ecoVestingTimer;
    mapping (address => mapping ( uint => uint )) public ecoVestingWallet;
    
    mapping (address => uint) public fnfLockTimer;
    mapping (address => mapping ( uint => uint )) public fnfLockWallet;
    
    mapping (address => uint) public privateLockTimer;
    mapping (address => mapping ( uint => uint )) public privateLockWallet;
    
    bool public tokenLock = true;
    bool public saleTime = true;
    uint public endSaleTime = 0;
    
    event AdvSptIssue(address indexed _to, uint _tokens);
    event TeamIssue(address indexed _to, uint _tokens);
    event MktIssue(address indexed _to, uint _tokens);
    event EcoIssue(address indexed _to, uint _tokens);
    event SaleIssue(address indexed _to, uint _tokens);
    
    event Burn(address indexed _from, uint _value);
    
    event TokenUnLock(address indexed _to, uint _tokens);
    event EndSale(address indexed _to, uint _tokens);
    
    constructor() public
    {
        name        = "ITAM";
        decimals    = 18;
        symbol      = "ITAM";
        
        totalTokenSupply    = 0;
        
        tokenIssuedAdvSpt   = 0;
        tokenIssuedTeam     = 0;
        tokenIssuedMkt      = 0;
        tokenIssuedEco      = 0;
        tokenIssuedSale     = 0;
        
        fnfIssuedSale       = 0;
        privateIssuedSale   = 0;
        publicIssuedSale    = 0;

        burnTokenSupply     = 0;
        
        require(maxTotalSupply == maxTotalSupply + maxAdvSptSupply + maxTeamSupply + maxMktSupply + maxTeamSupply + maxEcoSupply + maxSaleSupply);
        require(maxSaleSupply == maxFnFSaleSupply + maxPrivateSaleSupply + maxPublicSaleSupply);
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
    
    function balanceOfAll(address _who) view public returns (uint)
    {
        uint balance = balances[_who];
        uint fnfBalances = (fnfLockWallet[_who][0] + fnfLockWallet[_who][1] + fnfLockWallet[_who][2] + fnfLockWallet[_who][3] + fnfLockWallet[_who][4]);
        uint privateBalances = (privateLockWallet[_who][0] + privateLockWallet[_who][1] + privateLockWallet[_who][2] + privateLockWallet[_who][3] + privateLockWallet[_who][4] + privateLockWallet[_who][5]);
        balance = balance.add(fnfBalances);
        balance = balance.add(privateBalances);
        
        return balance;
    }
    
    function transfer(address _to, uint _value) public returns (bool) 
    {
        require(isTransferable(msg.sender) == true);
        require(isTransferable(_to) == true);
        require(balances[msg.sender] >= _value);
        
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        
        emit Transfer(msg.sender, _to, _value);
        
        return true;
    }
    
    function approve(address _spender, uint _value) public returns (bool)
    {
        require(isTransferable(msg.sender) == true);
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
        require(isTransferable(_from) == true);
        require(isTransferable(_to) == true);
        require(balances[_from] >= _value);
        require(approvals[_from][msg.sender] >= _value);
        
        approvals[_from][msg.sender] = approvals[_from][msg.sender].sub(_value);
        balances[_from] = balances[_from].sub(_value);
        balances[_to]  = balances[_to].add(_value);
        
        emit Transfer(_from, _to, _value);
        
        return true;
    }
    
    // -----
    
    // Vesting Issue Function -----
    
    function advSptIssueVesting(address _to, uint _time) onlyOwner public
    {
        require(saleTime == false);
        require(teamVestingTime >= _time);
        
        uint time = now;
        require( ( ( endSaleTime + (_time * teamVestingDate) ) < time ) && ( teamVestingTimeAtSupply[_time] > 0 ) );
        
        uint tokens = teamVestingTimeAtSupply[_time];

        require(maxTeamSupply >= tokenIssuedTeam.add(tokens));
        
        balances[_to] = balances[_to].add(tokens);
        teamVestingTimeAtSupply[_time] = 0;
        
        totalTokenSupply = totalTokenSupply.add(tokens);
        tokenIssuedTeam = tokenIssuedTeam.add(tokens);
        
        emit TeamIssue(_to, tokens);
    }
    
    // Issue Function -----
    
    function publicIssue(address _to, uint _value) onlyOwner public
    {
        uint tokens = _value * E18;
        require(maxSaleSupply >= tokenIssuedSale.add(tokens));
        
        balances[_to] = balances[_to].add(tokens);
        
        totalTokenSupply = totalTokenSupply.add(tokens);
        tokenIssuedSale = tokenIssuedSale.add(tokens);
        publicIssuedSale = publicIssuedSale.add(tokens);
        
        emit SaleIssue(_to, tokens);
    }
    
    // -----
    
    // Lock Function -----
    
    function isTransferable(address _who) private view returns (bool)
    {
        if(blackLists[_who] == true)
        {
            return false;
        }
        if(tokenLock == false)
        {
            return true;
        }
        else if(msg.sender == owner)
        {
            return true;
        }
        
        return false;
    }
    
    function setTokenUnlock() onlyOwner public
    {
        require(tokenLock == true);
        require(saleTime == false);
        
        tokenLock = false;
    }
    
    function setTokenLock() onlyOwner public
    {
        require(tokenLock == false);
        
        tokenLock = true;
    }
    
    function privateUnlock(address _to) onlyOwner public
    {
        require(tokenLock == false);
        require(saleTime == false);
        
        uint time = now;
        uint unlockTokens = 0;

        if( (time >= endSaleTime.add(month)) && (privateFirstWallet[_to] > 0) )
        {
            balances[_to] = balances[_to].add(privateFirstWallet[_to]);
            unlockTokens = unlockTokens.add(privateFirstWallet[_to]);
            privateFirstWallet[_to] = 0;
        }
        
        if( (time >= endSaleTime.add(month * 2)) && (privateSecondWallet[_to] > 0) )
        {
            balances[_to] = balances[_to].add(privateSecondWallet[_to]);
            unlockTokens = unlockTokens.add(privateSecondWallet[_to]);
            privateSecondWallet[_to] = 0;
        }
        
        emit TokenUnLock(_to, unlockTokens);
    }
    
    // -----
    
    // ETC / Burn Function -----
    
    function () payable external
    {
        revert();
    }
    
    function endSale() onlyOwner public
    {
        require(saleTime == true);
        
        saleTime = false;
        
        uint time = now;
        
        endSaleTime = time;
        
        for(uint i = 1; i <= teamVestingTime; i++)
        {
            teamVestingTimeAtSupply[i] = teamVestingTimeAtSupply[i].add(teamVestingSupplyPerTime);
        }
        
        for(uint i = 1; i <= advisorVestingTime; i++)
        {
            advisorVestingTimeAtSupply[i] = advisorVestingTimeAtSupply[i].add(advisorVestingSupplyPerTime);
        }
    }
    
    function withdrawTokens(address _contract, uint _decimals, uint _value) onlyOwner public
    {

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
    
    function burnToken(uint _value) onlyOwner public
    {
        uint tokens = _value * E18;
        
        require(balances[msg.sender] >= tokens);
        
        balances[msg.sender] = balances[msg.sender].sub(tokens);
        
        burnTokenSupply = burnTokenSupply.add(tokens);
        totalTokenSupply = totalTokenSupply.sub(tokens);
        
        emit Burn(msg.sender, tokens);
    }
    
    function close() onlyOwner public
    {
        selfdestruct(msg.sender);
    }
    
    // -----
}
