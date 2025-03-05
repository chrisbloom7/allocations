class AllocationService
  attr_reader :allocation, :allocated, :investors

  def initialize(allocation_data)
    allocation_data => { allocation_amount:, investor_amounts: }
    @allocation = allocation_amount.to_f.round(2)
    @investors = map_investor_amounts(investor_amounts)
    reset!
  end

  # FUNDING RULES:
  # 1. No investor should ever have a final amount that is greater than what they requested.
  # 2. No allocation should be left unused if an investor wants it.
  # 3. All allocation should be distributed proratably based on the average investment amount of the investors.
  #
  # EXAMPLE:
  # Available allocation: $100
  # Investor A requested to invest $150
  # Investor B requested to invest $50

  # Investor A has a historical average investment size of $100
  # Investor B has a historical average investment size of $25

  # After proration:
  # Investor A will invest $100 * (100 / (100 + 25)) = $80
  # Investor B will invest $100 * (25 / (100 + 25)) = $20
  def fund!
    reset!

    log "Requested allocation: #{allocation}", level: :debug, indent: 2

    # Loop to fund
    while allocated < allocation && amount_to_raise >= 0.01
      available_investors = investors.select(&:available?)
      log "Raised so far: #{allocated}", level: :debug, indent: 4
      log "Investors available to invest: #{available_investors.size}", level: :debug, indent: 4
      return allocated if available_investors.none?

      log "Left to raise: #{amount_to_raise}", level: :debug, indent: 4

      total_average_investments = available_investors.sum(&:average_amount)
      log "Total avg investments: #{total_average_investments}", level: :debug, indent: 4

      available_investors.each do |investor|
        log "Prorating #{investor.name}", level: :debug, indent: 6
        average_amount = investor.average_amount
        log "#{investor.name} proration amount: #{average_amount}", level: :debug, indent: 6

        log "Proration formula: #{amount_to_raise} * (#{average_amount} / #{total_average_investments})", level: :debug, indent: 6
        prorated_investment = (amount_to_raise * (average_amount / total_average_investments)).round(2)
        log "Prorated @ #{prorated_investment}", level: :debug, indent: 6

        invested = investor.fund(prorated_investment)
        log "Invested: #{invested}", level: :debug, indent: 6
        @allocated = (@allocated + invested).round(2)
      end
      log "Raise this round: #{allocated}", level: :debug, indent: 4
    end

    log "Allocated: #{allocated}", level: :debug, indent: 2
    @allocated
  end

  def funding_status
    if allocated == allocation
      :fully_funded
    elsif allocated == 0
      :unfunded
    elsif allocated < allocation
      :partially_funded
    elsif allocated > allocation
      :over_funded
    end
  end

  def amount_to_raise
    (allocation - allocated).round(2)
  end
  alias remaining amount_to_raise

  # For testing
  def reset!
    @allocated = 0
    @investors.each(&:reset!)
  end

  def to_h
    {
      allocation_amount: allocation,
      allocated:,
      remaining:,
      funding_status:,
      investor_amounts: investors.map(&:to_h)
    }
  end

  def map_investor_amounts(investor_amounts)
    investor_amounts.map do |data|
      next data if data === Investor

      Investor.new(data)
    end
  end
  private :map_investor_amounts

  def log(msg, label: nil, level: :info, indent: 0, break_after: false)
    log_level = case level
    when :debug
                  Logger::DEBUG
    when :info
                  Logger::INFO
    else
                  Logger::UNKNOWN
    end

    case msg
    when String
      prefix = "  " * indent
      Rails.logger.log log_level, prefix + msg.to_s
    else
      Rails.logger.log log_level, "#{label}\n#{"--" * indent}------------------------------" unless label.nil?
      Rails.logger.log log_level, msg
      Rails.logger.log log_level, "#{"--" * indent}------------------------------" unless label.nil?
    end

    Rails.logger.log log_level, "" if break_after
  end
  private :log

  class Investor
    attr_reader :name, :requested_amount, :average_amount, :invested

    def initialize(investor_amount)
      investor_amount => { name:, requested_amount:, average_amount: }
      @name = name
      @requested_amount = requested_amount.to_f.round(2)
      @average_amount = average_amount.to_f.round(2)
      reset!
    end

    def proration_amount
      [ requested_amount, average_amount ].min
    end

    def fund(amount)
      if amount + invested > requested_amount
        amount = (requested_amount - invested).round(2)
      end

      @invested = (@invested + amount).round(2)
      amount
    end

    def investment_status
      if invested == requested_amount
        :fully_invested
      elsif invested == 0
        :uninvested
      elsif invested < requested_amount
        :partially_invested
      elsif invested > requested_amount
        :over_invested
      end
    end

    def available?
      %i[uninvested partially_invested].include?(investment_status)
    end

    def reset!
      @invested = 0
    end

    def to_h
      {
        name:,
        requested_amount:,
        average_amount:,
        invested:,
        investment_status:,
        available: available?
      }
    end
  end
end
