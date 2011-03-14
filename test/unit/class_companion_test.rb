require 'test_helper'

module IndexTanked

  class ClassCompanionTest < Test::Unit::TestCase
    context "Initializing a class companion" do
      setup do
        Configuration.url = "http://example.com"
        Configuration.index = "test_index"
      end

      should "raise an error if no url is provided" do
        assert_raises IndexTanked::IndexTankURLNotProvidedError do
          Configuration.url = nil
          companion = ClassCompanion.new
        end
      end

      should "raise an error if no index is provided" do
        assert_raises IndexTanked::IndexTankIndexNameNotProvidedError do
          Configuration.index = nil
          companion = ClassCompanion.new
        end
      end
    end

    context "A class companion object" do
      setup do
        @companion = ClassCompanion.new(:index => "text_index",
                                        :url   => "http://example.com")
      end

      should "have a doc_id method that defines how to derive a doc_id for an instance" do
        PretendInstance = Struct.new(:id)
        pretend_instance = PretendInstance.new(42)

        @companion.doc_id(proc { |instance| "BlogPost:#{instance.id}" })

        assert_equal "BlogPost:42", @companion.get_value_from(pretend_instance, @companion.doc_id_value)
      end

      context "the field method" do
        context "when provided with one argument" do
          setup do
            @companion.field :id
          end

          should "add an array to the field list" do
            assert_equal 1, @companion.fields.size
            assert @companion.fields.first.is_a? Array
          end

          context "the array" do
            setup do
              @array = @companion.fields.first
            end

            should "have 3 elements" do
              assert_equal 3, @array.size
            end

            should "consist the name of the field to be indexed, the method to call, and an empty options hash" do
              assert_equal :id, @array[0]
              assert_equal :id, @array[1]
              assert_equal({}, @array[2])
            end
          end
        end

        context "when provided with two arguments" do
          context "where the second argument is not a hash" do
            setup do
              @id_lambda = lambda { |instance| instance.index_id }
              @companion.field :id, @id_lambda
            end

            should "add an array to the field list" do
              assert_equal 1, @companion.fields.size
              assert @companion.fields.first.is_a? Array
            end

            context "the array" do
              setup do
                @array = @companion.fields.first
              end

              should "have 3 elements" do
                assert_equal 3, @array.size
              end

              should "consist the name of the field to be indexed, the method to call, and an empty options hash" do
                assert_equal :id, @array[0]
                assert_equal @id_lambda, @array[1]
                assert_equal({}, @array[2])
              end
            end
          end

          context "where the second argument is a hash" do
            setup do
              @companion.field :id, :text => nil
            end

            should "add an array to the field list" do
              assert_equal 1, @companion.fields.size
              assert @companion.fields.first.is_a? Array
            end

            context "the array" do
              setup do
                @array = @companion.fields.first
              end

              should "have 3 elements" do
                assert_equal 3, @array.size
              end

              should "consist the name of the field to be indexed, the method to call, and the hash provided" do
                assert_equal :id, @array[0]
                assert_equal :id, @array[1]
                assert_equal({:text => nil}, @array[2])
              end
            end
          end
        end
      end

      context "when provided with three arguments" do
        setup do
          @id_lambda = lambda { |instance| instance.index_id }
          @companion.field :id, @id_lambda, :text => nil
        end

        should "add an array to the field list" do
          assert_equal 1, @companion.fields.size
          assert @companion.fields.first.is_a? Array
        end

        context "the array" do
          setup do
            @array = @companion.fields.first
          end

          should "have 3 elements" do
            assert_equal 3, @array.size
          end

          should "consist the name of the field to be indexed, the method to call, and the hash provided" do
            assert_equal :id, @array[0]
            assert_equal @id_lambda, @array[1]
            assert_equal({:text => nil}, @array[2])
          end
        end
      end
    end
  end
end