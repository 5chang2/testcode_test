# Rails test code test

## TDD?

>테스트 주도 개발(Test-driven development TDD)은 매우 짧은 개발 사이클을 반복하는 소프트웨어 개발 프로세스 중 하나이다. 
우선 개발자는 바라는 향상 또는 새로운 함수를 정의하는 (초기적 결함을 점검하는) 자동화된 테스트 케이스를 작성한다. 
그런 후에, 그 케이스를 통과하기 위한 최소한의 양의 코드를 생성한다. 그리고 마지막으로 그 새 코드를 표준에 맞도록 리팩토링한다. 
이 기법을 개발했거나 '재발견' 한 것으로 인정되는 Kent Beck은 2003년에 TDD가 단순한 설계를 장려하고 자신감을 불어넣어준다고 말하였다.


![image](https://static1.squarespace.com/static/50c9c50fe4b0a97682fac903/t/53eb775fe4b044b3ea5cf15f/1407940448579/)

TDD를 이용하여 도서관리 페이지를 만들어볼 예정입니다.

## 명세작성

제일 먼저 할 일은 페이지가 가져야 할 기능에 대해서 명세를 작성하는 일입니다.

* 책을 등록 한다.
  * isbn : 숫자와 '-' 만 가능
  * price : 음수와 0 안됨
  * cd : 필수항목이 아님(true or false)
  * 나머지 : 필수입력
* 목록을 출력한다.
* 책의 정보를 확인 할 수 있다.
* 책의 정보를 수정 할 수 있다.
* 책의 정보를 삭제 할 수 있다.

## Scaffolding

스캐폴딩을 사용하여 기본 도서관리 페이지를 만들어 봅시다.

```bash
rails g scaffold book isbn:string title:string price:integer publish:string published:date cd:boolean
```
## 내용 없는 book 생성 불가

가장 먼저 책을 등록할때 내용이 없는 경우 저장이 안되는 코드를 작성해봅시다.
실패하는 테스트를 먼저 작성합니다.
assert_not은 뒤에 오는 test가 거짓이라고 단언한다. 하지만 우리 코드에서는 book.save가 정상적으로 실행 될 예정이기 때문에
오류가 발생할 것이다.

```ruby
test "should not save book without title" do
  book = Book.new         #아무내용도 없는 빈 book 생성
  assert_not book.save    #그리고 저장을 한다.
end
```

테스트를 실행하기 위하여 터미널에 다음의 명령어를 입력한다.

    rake test test/models/book_test.rb
    
다음과 같은 오류가 발생한다.

```bash
och8808:~/workspace $ rake test test/models/book_test.rb
Run options: --seed 43209

# Running:

F

Finished in 0.036295s, 27.5523 runs/s, 27.5523 assertions/s.

  1) Failure:
BookTest#test_should_not_save_book_without_title [/home/ubuntu/workspace/test/models/book_test.rb:6]:
Expected true to be nil or false

1 runs, 1 assertions, 1 failures, 0 errors, 0 skips
```

실패한 테스트에서 메세지를 출력하기 위하여 다음과 같이 코드를 작성한다.

```ruby
test "should not save book without title" do
  book = Book.new
  assert_not book.save, "Saved the book without a title"
end
```    

메세지 출력결과는 다음과 같다.

```bash    
och8808:~/workspace $ rake test test/models/book_test.rb
Run options: --seed 39229

# Running:

F

Finished in 0.041265s, 24.2336 runs/s, 24.2336 assertions/s.

  1) Failure:
BookTest#test_should_not_save_book_without_title [/home/ubuntu/workspace/test/models/book_test.rb:6]:
Saved the book without a title

1 runs, 1 assertions, 1 failures, 0 errors, 0 skips
```

테스트를 통과하기 위해서는 book.save 가 실패 해야 한다.(결과가 false가 나와야함)
우리가 작성한 명세에 따르면 book에 들어가야할 정보들이 모두 필수가 되어야 한다.
그렇기 때문에 book의 모든 항목에 validation을 넣는다.
다음과 같은 코드를 작성한다.

```ruby
class Book < ActiveRecord::Base
    validates :isbn, presence: true
    validates :title, presence: true
    validates :price, presence: true
    validates :publish, presence: true
    validates :published, presence: true
    validates :cd, presence: true
end
```

테스트코드
```ruby
require 'test_helper'

class BookTest < ActiveSupport::TestCase
  test "should not save book without title" do
    book = Book.new
    book.isbn = "12-3456-78-90"
    book.title = "책의제목"
    book.price = "10000"
    book.publish = "출판사"
    book.published = "2017-01-01"
    book.cd = true
    assert_not book.save, "빈내용있음"
  end
end
```
## price 는 0보다 커야됨

price의 값을 숫자로만 받고 그 값을 0보다 크도록 받기 위하여 먼저 실패하는 코드를 작성한다.
`book.invalid?`를 사용하여 음수와 0을 price로 받았을때 유효한지 검사한다.


```ruby
test "price must be positive" do
    book = Book.new( isbn: "12-3456-78-90",
                     title: "책의제목",
                     publish: "출판사",
                     published: "2017-01-01",
                     cd: true)
    book.price = -123
    assert book.invalid?, "negative price of a product must be invalid"
    assert book.errors.has_key?(:price), book.errors
    
    book.price = 0
    assert book.invalid?, "negative price of a product must be invalid"
    assert book.errors.has_key?(:price), "error"
    
    book.price = 1
    assert book.valid?, "valid"
    assert_empty book.errors, "no error"
end
```

테스트 실행

    rake test test/models/book_test.rb
 
검증하기

```ruby
class Book < ActiveRecord::Base
    validates_numericality_of :price, greater_than: 0
end
```

## isbn은 항상 숫자와 -

실패하는 코드 작성

```ruby
test "isbn must be num and -" do
    book = Book.new( title: "책의제목",
                     publish: "출판사",
                     price: 123,
                     published: "2017-01-01",
                     cd: true)

    book.isbn = "675=67-5567567-58775"
    assert_no_match( /\A[0-9-]+\z/, book.isbn, "isbn must be num and -" )    
end
```  

검증 추가
```ruby
validates_format_of :isbn, :with => /\A[0-9-]+\z/,
    :message => "Only number and -"
```
## 테스트 데이터베이스

test/fixtures/book_test.rb 픽스쳐 작성방법
```ruby
one:
  isbn: MyString
  title: MyString
  price: 1
  publish: MyString
  published: 2017-09-20
  cd: false

<% 1000.times do |n| %>
book_<%= n %>:
  isbn: <%= "#{n}" %>
  title: <%= "book#{n}" %>
  price: <%= n %>
  publish: <%= "p#{n}" %>
  published: 2017-09-20
  cd: true
<% end %>
```

## 통합테스트

파일 생성
    
    bin/rails generate integration_test user_flows
    
user flow test - index페이지 들어가기, 글작성하기

```ruby
require 'test_helper'

class UserFlowsTest < ActionDispatch::IntegrationTest
  test "can see the welcome page" do
    get "/"
    assert_select "h1", "Hi"
  end
  
  test "can create a book" do
    get "/books/new"
    assert_response :success

    post "/books", book: { isbn: "123", title: "123", price: 1, publish: "123", published: "2017-01-01", cd: 1 }
    #post "/articles",  params: { article: { title: "can create", body: "article successfully." } } 공식문서에 이렇게 써있는데 왜 안됨 ???? 짜증나네 ㅠㅠㅠㅠ
    assert_response :redirect
    follow_redirect!
    assert_response :success
    #assert_select "p", "Title:\n  can create"
  end
end

```

## 컨트롤러 기능 테스트

레일스는 test_should_get_index 테스트에서 index라고 불리는 액션에 대한 요청을 흉내 내고, 이 요청이 성공적이고, 올바른 응답을 생성했음을 확인합니다.

get 메소드는 요청을 실행하고 결과를 @response에 생성합니다. 이 메소드는 6개의 인자를 받을 수 있습니다.

요청을 보낼 컨트롤러의 액션. 문자열이나 라우팅 헬퍼(i.e. articles_url)를 받을 수 있습니다.
- params: 액션에 넘겨줄 매개변수의 해시(e.g. 쿼리 문자열 매개변수나 article 변수).
- headers: 요청과 함께 넘길 헤더를 설정.
- env: 필요한 경우 요청 환경 변수를 변경할 때 사용.
- xhr:요청이 Ajax 요청인지 아닌지 지정. true이면 Ajax로 간주.
- as: 요청의 content type을 지정. :json은 기본으로 사용할 수 있음.

예제
```ruby
#show 액션을 params의 id에 12를 넘기고 HTTP_REFERER 헤더를 설정하여 호출
get :show, params: { id: 12 }, headers: { "HTTP_REFERER" => "http://example.com/home" }

#update 액션을 params의 id에 12를 넘기고 Ajax 요청으로 호출
patch update_url, params: { id: 12 }, xhr: true
```

컨트롤러 테스트는 스캐폴딩을 사용할때 자동으로 생성 되었다. 
`test/controllers/books_controller_test.rb` 파일확인.

```ruby
require 'test_helper'

class BooksControllerTest < ActionController::TestCase
  setup do
    @book = books(:one)   #books.yml 파일에서 생성했던 one: 
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:books)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create book" do
    assert_difference('Book.count') do
      post :create, book: { cd: @book.cd, isbn: @book.isbn, price: @book.price, publish: @book.publish, published: @book.published, title: @book.title }
    end

    assert_redirected_to book_path(assigns(:book))
  end

  test "should show book" do
    get :show, id: @book
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @book
    assert_response :success
  end

  test "should update book" do
    patch :update, id: @book, book: { cd: @book.cd, isbn: @book.isbn, price: @book.price, publish: @book.publish, published: @book.published, title: @book.title }
    assert_redirected_to book_path(assigns(:book))
  end

  test "should destroy book" do
    assert_difference('Book.count', -1) do
      delete :destroy, id: @book
    end

    assert_redirected_to books_path
  end
end

```

```ruby
one:
  isbn: MyString
  title: MyString
  price: asdf
  publish: MyString
  published: 2017-09-20
  cd: false
```

price 를 문자로 넣어봄

```bash
och8808:~/workspace (master) $ rake test test/controllers/books_controller_test.rb 
Run options: --seed 40479

# Running:

F.....F

Finished in 1.802719s, 3.8830 runs/s, 5.5472 assertions/s.

  1) Failure:
BooksControllerTest#test_should_create_book [/home/ubuntu/workspace/test/controllers/books_controller_test.rb:20]:
"Book.count" didn't change by 1.
Expected: 1003
  Actual: 1002

  2) Failure:
BooksControllerTest#test_should_update_book [/home/ubuntu/workspace/test/controllers/books_controller_test.rb:39]:
Expected response to be a <redirect>, but was <200>

7 runs, 10 assertions, 2 failures, 0 errors, 0 skips
```

에러가난 20번째와 39번째 줄

```ruby
  test "should create book" do
    assert_difference('Book.count') do  #assert_difference 블록을 실행하기 전후에 평가한 표현식의 결과로 반환된 숫자의 차이를 테스트함.
      post :create, book: { cd: @book.cd, isbn: @book.isbn, price: @book.price, publish: @book.publish, published: @book.published, title: @book.title }
    end

    assert_redirected_to book_path(assigns(:book))
  end
  
  test "should update book" do
    patch :update, id: @book, book: { cd: @book.cd, isbn: @book.isbn, price: @book.price, publish: @book.publish, published: @book.published, title: @book.title }
    assert_redirected_to book_path(assigns(:book))
    
    #assert_redirected_to(options = {}, message=nil)
    #넘겨진 옵션이 마지막에 실행된 액션의 리다이렉션과 매칭한다고 보장. 
  end
  
```

###### 20번째 줄 에러


`should create book` 가 실행되고 `assert_difference`단언에 의해 `book.count`의 값이 
1차이가 있어야 하는데 1003의 기대치가 아닌 1002(book.yml에서 one, two 와 1000개의 데이터 생성)의 값이 나와 실패

###### 39번째 줄 에러
`Expected response to be a <redirect>, but was <200>`

price 값에 문자가 들어가 저장했을때 오류 발생. 컨트롤러에서 저장이 성공해서`redirect_to @book`가 
실행 되야 하지만 저장이 실패 하여 `:new` 가 요청되어 에러 발생

## 뷰테스트

title 테스 안의 값 확인 테스트
```ruby
assert_select 'title', "LikeLion"
```


