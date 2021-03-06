class PostgisExtend < ActiveRecord::Migration[4.2]
  def change
    # Deprecated.  This is not needed when rake db:setup is used
    # ActiveRecord::Base.connection.execute('CREATE EXTENSION postgis')
    # ActiveRecord::Base.connection.execute('CREATE EXTENSION postgis_topology')
    enable_extension "postgis" # https://github.com/rgeo/activerecord-postgis-adapter/issues/302#issuecomment-558717144
    enable_extension "postgis_topology"
  end
end
