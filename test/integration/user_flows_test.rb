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
