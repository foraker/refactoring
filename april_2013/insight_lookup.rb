class InsightLookup
  def initialize(applicant_score, target_score)
    @qualitative_applicant_score  = Qualitative::Score.from_quanity(applicant_score)
    @qualitative_target_score     = Qualitative::Score.from_quanity(target_score)
    @qualitative_score_comparison = Qualitative::ScoreComparison.new(@qualitative_applicant_score, @qualitative_target_score)
  end

  def lookup
    @qualitative_target_score.present? ? compose_differentiating_insight : applicant_insight
  end
  alias :analyze :lookup

  private

  def applicant_insight
    InsightRepository.find(applicant_key, :default => :underdeveloped)
  end

  def compose_differentiating_insight
    InsightRepository.find(applicant_key, :scope => [target_scope, differentiating_scope])
  end

  def target_scope
    @qualitative_target_score.to_sym
  end

  def differentiating_scope
    @qualitative_score_comparison.qualitative_difference if @qualitative_score_comparison.scores_similiar?
  end

  def applicant_key
    if @qualitative_applicant_score.low? then :underdeveloped
    elsif @qualitative_applicant_score.high? then :overdeveloped
    end
  end

  module Qualitative
    class Distribution
      QUALITIES = {
        :low     => 0..39,
        :general => 40..60,
        :high    => 60..100
      }

      def self.quatity_to_quality(quantity)
        QUALITIES.detect { |segment, range| range.include?(quantity) }[0]
      end
    end

    class Score < Struct.new(:quantative_score)
      include Comparable

      class << self
        alias :from_quanity :new
      end

      def low?
        quality == :low
      end

      def high?
        quality == :high
      end

      def general?
        quality == :general
      end

      def <=>(other)
        quantative_score <=> other.quantative_score
      end

      def present?
        !!quantative_score
      end

      def quality
        Distribution.quatity_to_quality(quantative_score)
      end
      alias :to_sym :quality
    end

    class ScoreComparison < Struct.new(:applicant_score, :target_score)
      def scores_similiar?
        applicant_score.quality == target_score.quality
      end

      def qualitative_difference
        if target_score.low? && applicant_score.low?
          (target_score > applicant_score) ? :more : :less
        elsif target_score.high? && applicant_score.high?
          (target_score < applicant_score) ? :more : :less
        end
      end
    end
  end

  class InsightRepository
    DIRECT_INSIGHTS = {
      :overdeveloped  => 'applicant overdeveloped text',
      :underdeveloped => 'applicant underdeveloped text',
    }

    COMPOSED_INSIGHTS = {
      :general_overdeveloped   => 'target general applicant overdeveloped text',
      :general_underdeveloped  => 'target general applicant underdeveloped text',
      :high_more_overdeveloped => 'target high applicant more overdeveloped text',
      :high_less_overdeveloped => 'target high applicant less overdeveloped text',
      :high_underdeveloped     => 'target high applicant underdeveloped text',
      :low_more_underdeveloped => 'target low applicant more underdeveloped text',
      :low_less_underdeveloped => 'target low applicant less underdeveloped text',
      :low_overdeveloped       => 'target low applicant overdeveloped text',
    }

    def self.find(key, options = {})
      options[:scope] ? compose(key, options) : DIRECT_INSIGHTS[key || options[:default]]
    end

    def self.compose(key, options)
      key = options[:scope].push(key).compact.join('_').to_sym
      COMPOSED_INSIGHTS[key]
    end
  end
end
