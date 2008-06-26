module ActiveScaffold::Config
  class Reorder < Base
    self.crud_type = :update

    def initialize(core_config)
      @core = core_config
    end

    MOTION_METHODS = {
      'reorder_up' => :move_higher,
      'reorder_down' => :move_lower,
      'reorder_top' => :move_to_top,
      'reorder_bottom' => :move_to_bottom
    }
  end
end
