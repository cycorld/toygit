# ToyGit

## Commands

- list : toyid를 "(chapter)-(step)-(action)" 형태로 붙여서 로그를 보여준다.
- goto : fix 브랜치를 만들면서 지정된 toyid에 해당하는 커밋으로 이동한다.
- return : master 브랜치를 fix 브랜치로 리베이스 한다.
- delete : 지정된 toyid에 해당하는 커밋을 제거하고 리베이스 한다.
- change : chapter나 step명을 일괄적으로 변경한다.
  - (ex1) `toygit change chapter 1 "메인 컨트롤러 만들기"`
  - (ex2) `toygit change step 2-0 "유저 등록하는 api 라우팅 추가"`

## Todo

(없음)
