Feature: minitest support

  minitest is supported by Bogus both with the classic assert-style syntax and the minitest/spec expectation syntax.

  At the moment we support all of Bogus features in minitest except for contract verification.

  Background:
    Given a file named "library.rb" with:
    """ruby
    class Library
      def self.books
      end

      def checkout(book)
      end

      def return_book(book)
      end
    end
    """

    Given a file named "book_index.rb" with:
    """ruby
    class BookIndex
      def self.by_author(author)
        Library.books.select{|book| book[:author] == author}
      end
    end
    """

    Given a file named "student.rb" with:
    """ruby
    class Student
      def initialize(library)
        @library = library
      end

      def study(*book_titles)
        book_titles.each do |book_title|
          @library.checkout(book_title)
        end
      end
    end
    """

  Scenario: Auto-verification of unsatisfied mocks
    Then minitest file "foo_test.rb" with the following content should fail:
    """ruby
    require 'minitest/autorun'
    require 'bogus/minitest'

    require_relative 'student'
    require_relative 'library'

    class StudentTest < MiniTest::Unit::TestCase
      def test_library_checkouts
        library = fake(:library)
        student = Student.new(library)
        mock(library).checkout("Moby Dick")
        mock(library).checkout("Sherlock Holmes")

        student.study("Moby Dick")
      end
    end
    """

  Scenario: Spying on method calls with assert syntax
    Then minitest file "foo_test.rb" with the following content should pass:
    """ruby
    require 'minitest/autorun'
    require 'bogus/minitest'

    require_relative 'student'
    require_relative 'library'

    class StudentTest < MiniTest::Unit::TestCase
      def setup
        @library = fake(:library)
      end

      def test_library_checkouts
        student = Student.new(@library)

        student.study("Moby Dick", "Sherlock Holmes")

        assert_received @library, :checkout, ["Moby Dick"]
        assert_received @library, :checkout, ["Sherlock Holmes"], "optional message"
        refute_received @library, :return_book, ["Moby Dick"]
      end
    end
    """

  Scenario: Spying on method calls with expectation syntax
    Then minitest file "foo_spec.rb" with the following content should pass:
    """ruby
    require 'minitest/autorun'
    require 'bogus/minitest/spec'

    require_relative 'student'
    require_relative 'library'

    describe Student do
      describe "#study" do
        fake(:library)

        it "studies using books from library" do
          student = Student.new(library)

          student.study("Moby Dick", "Sherlock Holmes")

          library.must_have_received :checkout, ["Moby Dick"]
          library.must_have_received :checkout, ["Sherlock Holmes"]
          library.wont_have_received :return_book, ["Moby Dick"]
        end
      end
    end
    """

  Scenario: Describe-level class faking
    Then minitest file "foo_spec.rb" with the following content should pass:
    """ruby
    require 'minitest/autorun'
    require 'bogus/minitest/spec'

    require_relative 'book_index'
    require_relative 'library'

    describe BookIndex do
      fake_class(Library, books: [])

      it "returns books written by author" do
        BookIndex.by_author("Mark Twain").must_equal []
      end
    end
    """