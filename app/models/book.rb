class Book < ActiveRecord::Base
    validates_format_of :isbn, :with => /\A[0-9-]+\z/,
    :message => "Only number and -"
    validates :title, presence: true
    validates_numericality_of :price, greater_than: 0
    #validates_numericality_of :price, only_integer: true
    #validates :price, presence: true
    validates :publish, presence: true
    validates :published, presence: true
    #validates :cd, presence: true # cd 값은 없을수도 있음 주석처리
end
