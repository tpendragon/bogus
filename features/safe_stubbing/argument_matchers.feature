Feature: Argument matchers

  Bogus supports some argument matchers for use, when you don't really care about exact equality of arguments passed in or spied on.

  Background:
    Given a file named "catalog.rb" with:
    """ruby
    class Catalog
      def self.books_by_author_and_title(author, title)
      end
    end
    """

  Scenario: Stubbing methods with any arguments
    Then the following test should pass:
    """ruby
    require_relative 'catalog'

    stub(Catalog).books_by_author_and_title(any_args) { :some_book }

    expect(Catalog.books_by_author_and_title("Arthur Conan Doyle", "Sherlock Holmes")).to eq(:some_book)
    """

  Scenario: Stubbing methods with some wildcard arguments
    Then the following test should pass:
    """ruby
    require_relative 'catalog'

    stub(Catalog).books_by_author_and_title(any_args) { :some_book }
    stub(Catalog).books_by_author_and_title("Mark Twain", anything) { :twains_book }

    expect(Catalog.books_by_author_and_title("Mark Twain", "Tom Sawyer")).to eq(:twains_book)
    expect(Catalog.books_by_author_and_title("Mark Twain", "Huckleberry Finn")).to eq(:twains_book)
    expect(Catalog.books_by_author_and_title("Arthur Conan Doyle", "Sherlock Holmes")).to eq(:some_book)
    """

  Scenario: Stubbing methods with proc arguments matcher
    Then the following test should pass:
    """ruby
    require_relative 'catalog'

    stub(Catalog).books_by_author_and_title(any_args) { :some_book }
    stub(Catalog).books_by_author_and_title(with{|author| author =~ /Twain/ }) { :twains_book }

    expect(Catalog.books_by_author_and_title("Mark Twain", "Tom Sawyer")).to eq(:twains_book)
    expect(Catalog.books_by_author_and_title("M. Twain", "Huckleberry Finn")).to eq(:twains_book)
    expect(Catalog.books_by_author_and_title("Arthur Conan Doyle", "Sherlock Holmes")).to eq(:some_book)
    """

  Scenario: Stubbing methods with proc argument matcher
    Then the following test should pass:
    """ruby
    require_relative 'catalog'

    stub(Catalog).books_by_author_and_title(any_args) { :some_book }
    stub(Catalog).books_by_author_and_title(matches{|author| author =~ /Twain/ }, "Tom Sawyer") { :twains_book }

    expect(Catalog.books_by_author_and_title("Mark Twain", "Tom Sawyer")).to eq(:twains_book)
    expect(Catalog.books_by_author_and_title("M. Twain", "Huckleberry Finn")).to eq(:some_book)
    expect(Catalog.books_by_author_and_title("Arthur Conan Doyle", "Sherlock Holmes")).to eq(:some_book)
    """

  Scenario: Stubbing methods with argument type matcher
    Then the following test should pass:
    """ruby
    require_relative 'catalog'

    stub(Catalog).books_by_author_and_title(any_args) { :some_book }
    stub(Catalog).books_by_author_and_title(any(String), any(String)) { :twains_book }

    expect(Catalog.books_by_author_and_title("Mark Twain", "Tom Sawyer")).to eq(:twains_book)
    expect(Catalog.books_by_author_and_title("M. Twain", :other_book)).to eq(:some_book)
    """
