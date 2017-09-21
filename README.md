# Rails test code test

## book만들기

1. isbn:string , 숫자 - 만 가능
2. title:string
3. price:integer , 음수 0 안됨
4. publish:string 
5. published:date 
6. cd:boolean

## Scaffolding

book 생성

    rails g scaffold book isbn:string title:string price:integer publish:string published:date cd:boolean

## title이 없는 book 생성 불가

실패하는 테스트를 먼저 작성

```ruby
test "should not save book without title" do
  book = Book.new
  assert_not book.save
end
```

테스트 실행

    rake test test/models/book_test.rb
    
1 failures

    och8808:~/workspace $ rake test test/models/book_test.rb
    Run options: --seed 43209
    
    # Running:
    
    F
    
    Finished in 0.036295s, 27.5523 runs/s, 27.5523 assertions/s.
    
      1) Failure:
    BookTest#test_should_not_save_book_without_title [/home/ubuntu/workspace/test/models/book_test.rb:6]:
    Expected true to be nil or false
    
    1 runs, 1 assertions, 1 failures, 0 errors, 0 skips
    
메세지 출력하기
```ruby
test "should not save book without title" do
  book = Book.new
  assert_not book.save, "Saved the book without a title"
end
```    
메세지 출력결과
    
    och8808:~/workspace $ rake test test/models/book_test.rb
    Run options: --seed 39229
    
    # Running:
    
    F
    
    Finished in 0.041265s, 24.2336 runs/s, 24.2336 assertions/s.
    
      1) Failure:
    BookTest#test_should_not_save_book_without_title [/home/ubuntu/workspace/test/models/book_test.rb:6]:
    Saved the book without a title
    
    1 runs, 1 assertions, 1 failures, 0 errors, 0 skips
    
검증하기(모든 항목 필수)

    class Book < ActiveRecord::Base
        validates :isbn, presence: true
        validates :title, presence: true
        validates :price, presence: true
        validates :publish, presence: true
        validates :published, presence: true
        validates :cd, presence: true
    end


테스트코드

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

## price 는 0보다 커야됨

실패하는 코드작성
    
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

테스트 실행

    rake test test/models/book_test.rb
 
검증하기

    class Book < ActiveRecord::Base
        validates_numericality_of :price, greater_than: 0
    end
    
## isbn은 항상 숫자와 -

실패하는 코드 작성

    test "isbn must be num and -" do
        book = Book.new( title: "책의제목",
                         publish: "출판사",
                         price: 123,
                         published: "2017-01-01",
                         cd: true)
    
        book.isbn = "675=67-5567567-58775"
        assert_no_match( /\A[0-9-]+\z/, book.isbn, "isbn must be num and -" )    
    end
    
검증 추가

    validates_format_of :isbn, :with => /\A[0-9-]+\z/,
        :message => "Only number and -"

## 테스트 데이터베이스

test/fixtures/book_test.rb 픽스쳐 작성방법

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
    
## 컨트롤러 테스트