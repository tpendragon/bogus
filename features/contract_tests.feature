Feature: Contract tests

  Background:
    Given a file named "foo.rb" with:
    """ruby
    class Library
      def checkout(book)
      end
    end

    class Student
      def read(book, library = Libarary.new)
        library.checkout(book)
        # ...
      end
    end
    """
    And a spec file named "student_spec.rb" with:
    """ruby
    describe Student do
      fake(:library)

      it "reads books from library" do
        student = Student.new

        student.read("Moby Dick", library)

        library.should have_received.checkout("Moby Dick")
      end
    end
    """

  Scenario: Stubbing methods that exist on real object
    Then spec file with following content should pass:
    """ruby
    describe Library do
      verify_contract(:library)

      it "checks out books" do
        library = Library.new

        library.checkout("Moby Dick")
        
        # ...
      end
    end
    """
