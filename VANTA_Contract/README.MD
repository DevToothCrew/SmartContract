SafeMath
- https://blog.naver.com/soolmini/221256720072
- 추후 Wiki 추가 예정

OwnerHelper
- https://blog.naver.com/soolmini/221258425662
- 추후 Wiki 추가 예정

ERC20 InterFace
- ERC 20 기본 인터페이스

VantaToken
- VantaToken 컨트랙트

ERC20 Interface Function
- ERC 20 함수
- totalSupply : 총 발행량
- balanceOf : 개인 보유량
- transfer : 전송
- approve : 공유
- allowance : 공유량
- transferFrom : 공유 전송

Issue Function
- 토큰 발행 함수
- apSaleIssue : a grade private 판매 발행
- bpSaleIssue : b grade private 판매 발행
- saleIssue : public 판매 발행
- bdevIssue : Business Development 발행
- mktIssue : Marketing 발행
- rndIssue : R&D 발행
- reserveIssue : Reserve 발행
- teamIssue : Team & Founder 발행
- advisorIssue : Advisor & Early Supporters 발행

Lock Function
- 락 / 언락 함수
- isTransferable : 전송 가능 확인
- tokenLockUp : 전체 토큰 전송 락 / 락 해제
- apLockUp : a grade private 락 해제
- bpLockUp : b grade private 락 해제

ETC / Burn Function
- 기타 / 회수 / 소각 함수
- () payable : 폴백 함수 / 컨트랙트로 토큰 전송 못하게
- endSale : 세일 종료 함수 / 투자 회수도 불가능
- withdrawTokens : 토큰 회수
- setApTime : a grade private 락 해제 시간 설정 / 해제 시간 + 30일씩 추가
- setBpTime : b grade private 락 해제 시간 설정 / 해제 시간 + 30일씩 추가
- burnToken : 토큰 
