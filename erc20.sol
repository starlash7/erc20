// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.20;

import {IERC20} from "./IERC20.sol";
import {IERC20Metadata} from "./extensions/IERC20Metadata.sol";
import {Context} from "../../utils/Context.sol";
import {IERC20Errors} from "../../interfaces/draft-IERC6093.sol";


abstract contract ERC20 is Context, IERC20, IERC20Metadata, IERC20Errors {
    mapping(address account => uint256) private _balances;//지갑주소를 넣으면 잔고를 알려줘

    mapping(address account => mapping(address spender => uint256)) private _allowances;
    //address -> address -> uint로 맵핑, 얘가 쟤한테 얼만큼 허락해줬어?

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    //이름,심볼은 시작하자마자 정해진다.


    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    
    function name() public view virtual returns (string memory) {
        return _name;
    }

 
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    
    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }

    
    function balanceOf(address account) public view virtual returns (uint256) {
        return _balances[account];
        //주소를 넣어서 uint를 받아온다 -> return 값 account에 balances가 얼마있니?
        //예를 들어 비탈릭이 eth를 몇개가지고 있냐고 물어보면 key값으로 비탈릭의컨트랙트주소를 넣어야한다.
        //비탈릭의 usdt를 몇개 가지고 있어? key값으로 usdt컨트랙주소를 넣고 mapping해서 비탈릭지갑주소로 간다.
    }

  
    function transfer(address to, uint256 value) public virtual returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, value);
        return true;
        //transfer를 하면 transfer가 다른 transfer를 불러온다.
        //owner = 나 , to= 받는사람, value= 돈
    }

   
    function allowance(address owner, address spender) public view virtual returns (uint256) {
        return _allowances[owner][spender];
        //allowance(얘가 쟤한테 얼마쓸수있는지 허락해줬어?) mapping에서 가져옴
        //allowance를 approve를 한다고해서 돈이 바로 나가는것은 아니다.
    }

  
    function approve(address spender, uint256 value) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, value);
        return true;
        //approve 내가 누르는 함수, spender는 스마트컨트랙트
        //allowances를 허락해주는게 approve
    }

   
    function transferFrom(address from, address to, uint256 value) public virtual returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, value);
        _transfer(from, to, value);
        return true;
        //누가 누르는지를 봐야함(정산하는 단계) from=나, to=쟤 , value=돈, 근데 이거래는 게임이 실행시킨다.
        //allowance 함수를 호출
    }

   
    function _transfer(address from, address to, uint256 value) internal {
        if (from == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        if (to == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(from, to, value);
    }

   
    function _update(address from, address to, uint256 value) internal virtual {
        if (from == address(0)) {
            _totalSupply += value;
            //받는사람이 0주소면 totalSupply가 바뀐다
        } else {
            uint256 fromBalance = _balances[from];
            if (fromBalance < value) {
                revert ERC20InsufficientBalance(from, fromBalance, value);
                //가지고 있는 돈보다 많이보낼려고하면 revert
            }
            unchecked {
                _balances[from] = fromBalance - value;
            }
        }

        if (to == address(0)) {
            unchecked {
                _totalSupply -= value;
            }
        } else {
            unchecked {
                _balances[to] += value;
            }
        }

        emit Transfer(from, to, value);

    }

  
    function _mint(address account, uint256 value) internal {
        //account한테 value 만큼 mint해줘
        if (account == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(address(0), account, value);
    }

   
    function _burn(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        _update(account, address(0), value);
    }

    function _approve(address owner, address spender, uint256 value) internal {
        _approve(owner, spender, value, true);
    }

  
    function _approve(address owner, address spender, uint256 value, bool emitEvent) internal virtual {
        if (owner == address(0)) {
            revert ERC20InvalidApprover(address(0));
        }
        if (spender == address(0)) {
            revert ERC20InvalidSpender(address(0));
        }
        _allowances[owner][spender] = value; // 내가 spender한테 value만큼 allowances 해주세요~
        if (emitEvent) {
            emit Approval(owner, spender, value);
        }
    }

    
    function _spendAllowance(address owner, address spender, uint256 value) internal virtual {
            //owner =나, spender= 게임, value= 돈
            //나 게임한테 얼만큼 허락해 줬지?
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            if (currentAllowance < value)
                //ex.허락해준돈이 500원인데 1000원을하면 revert
             {
                revert ERC20InsufficientAllowance(spender, currentAllowance, value);
            }
            unchecked {
                _approve(owner, spender, currentAllowance - value, false);
            }
        }
    }
}