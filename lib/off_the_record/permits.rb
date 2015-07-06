module OffTheRecord

class Permits < Hash
  def add_filters(filters)
    filters.each do |filter|
      if filter.is_a?(Hash)
        merge!(filter)
      else
        merge!(filter => nil)
      end
    end
  end

  def to_permit_filters
    each_pair.each_with_object([]) do |pair, result|
      if pair.last.nil?
        result << pair.first
      else
        result << { pair.first => pair.last }
      end
    end
  end
end

end

