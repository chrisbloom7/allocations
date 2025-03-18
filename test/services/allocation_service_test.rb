require "test_helper"

class AllocationServiceTest < ActiveSupport::TestCase
  def setup
    @allocation_amount = 100
    @investor_amounts = [
      { name: "Investor A", requested_amount: 150, average_amount: 100 },
      { name: "Investor B", requested_amount: 50, average_amount: 25 }
    ]
    @service = AllocationService.new(allocation_amount: @allocation_amount, investor_amounts: @investor_amounts)
  end

  test "should allocate funds correctly" do
    @service.fund!
    assert_equal 100, @service.allocated
    assert_equal 0, @service.remaining
    assert_equal :fully_funded, @service.funding_status
  end

  test "should reset allocation" do
    @service.fund!
    @service.reset!
    assert_equal 0, @service.allocated
    assert_equal :unfunded, @service.funding_status
  end

  test "should return correct funding status" do
    assert_equal :unfunded, @service.funding_status
    @service.fund!
    assert_equal :fully_funded, @service.funding_status
  end

  test "should map investor amounts correctly" do
    investors = @service.send(:map_investor_amounts, @investor_amounts)
    assert_equal 2, investors.size
    assert_equal "Investor A", investors.first.name
    assert_equal 150, investors.first.requested_amount
    assert_equal 100, investors.first.average_amount
  end

  ALLOCATIONS_DATA_PATH = Rails.root.join("test/fixtures/files/allocations")
  Dir.glob("*_input.json", base: ALLOCATIONS_DATA_PATH, sort: true) do |input_file|
    test "Allocations from #{input_file}" do
      input_file_contents = File.read("#{ALLOCATIONS_DATA_PATH}/#{input_file}")
      allocation_data = JSON.parse(input_file_contents, symbolize_names: true)

      output_file = input_file.sub(/_input.json\z/, "_output.json")
      output_file_contents = File.read("#{ALLOCATIONS_DATA_PATH}/#{output_file}")
      expected_allocations = JSON.parse(output_file_contents, symbolize_names: false).tap do |json|
        json.each { |k, v| json[k] = v.to_f.round(2) }
      end

      allocation = AllocationService.new(allocation_data)
      allocation.fund!
      actual_allocations = allocation.to_h[:investor_amounts].inject({}) do |memo, investor|
        memo[investor[:name]] = investor[:invested]
        memo
      end

      assert_includes %i[fully_funded partially_funded], allocation.funding_status
      assert_equal expected_allocations, actual_allocations
      assert_empty allocation.investors.map(&:investment_status).select { |status| %i[uninvested over_invested].include?(status) }
    end
  end
end

class InvestorTest < ActiveSupport::TestCase
  def setup
    @investor_data = { name: "Investor A", requested_amount: 150, average_amount: 100 }
    @investor = AllocationService::Investor.new(@investor_data)
  end

  test "should initialize investor correctly" do
    assert_equal "Investor A", @investor.name
    assert_equal 150, @investor.requested_amount
    assert_equal 100, @investor.average_amount
    assert_equal 0, @investor.invested
  end

  test "should fund investor correctly" do
    amount = @investor.fund(80)
    assert_equal 80, amount
    assert_equal 80, @investor.invested
  end

  test "should not overfund investor" do
    amount = @investor.fund(160)
    assert_equal 150, amount
    assert_equal 150, @investor.invested
  end

  test "should return correct investment status" do
    assert_equal :uninvested, @investor.investment_status
    @investor.fund(80)
    assert_equal :partially_invested, @investor.investment_status
    @investor.fund(70)
    assert_equal :fully_invested, @investor.investment_status
  end

  test "should reset investor correctly" do
    @investor.fund(80)
    @investor.reset!
    assert_equal 0, @investor.invested
    assert_equal :uninvested, @investor.investment_status
  end
end
