require 'test_helper'

class BookTest < ActiveSupport::TestCase
  test "should not save book without title" do
    book = Book.new
    book.isbn = "12-3456-78-90"
    book.title = "책의제목"
    book.price = 10000
    #book.publish = "출판사"
    book.published = "2017-01-01"
    book.cd = true
    assert_not book.save, "빈내용있음"
  end
  
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
  
  test "isbn must be num and -" do
    book = Book.new( title: "책의제목",
                     publish: "출판사",
                     price: 123,
                     published: "2017-01-01",
                     cd: true)

    book.isbn = "675=67-5567567-58775"
    assert_no_match( /\A[0-9-]+\z/, book.isbn, "isbn must be num and -" )    
  end
end
