require "rack"

class Rack::SSI

  def initialize(app, options={ :max_depth => 5, :ext => ".shtml", :tag => '(<!--#include virtual="(.*)"\s*-->)' } )
    @app        = app
    @max_depth  = options[:max_depth]
    @ext        = options[:ext]
    @tag_regexp = Regexp.new(options[:tag])
  end

  def call(env)
    process_request(env)
  end

  private

  MAX_DEPTH = 5

  class Error < ::RuntimeError
  end

  def process_request(env)
    status, headers, enumerable_body = original_response = @app.call(env.dup)

    return original_response unless headers["Content-Type"].to_s.match(/(ht|x)ml/)

    return original_response unless @ext == ::File.extname(env['PATH_INFO'])

    body = join_body(enumerable_body)

    processed_body = process_include(env, body)

    processed_headers = headers.merge({
        "Content-Length" => processed_body.size.to_s,
        "Cache-Control" => "private, max-age=0, must-revalidate"
      })
    processed_headers.delete("Expires")
    processed_headers.delete("Last-Modified")
    processed_headers.delete("ETag")

    [status, processed_headers, [processed_body]]
  end

  def process_include(env, body, level=0)
    raise(Error, "Too many levels of SSI processing: level #{level} reached. We were about to request: #{env['REQUEST_URI']} // #{env['PATH_INFO']}") if level > (@max_depth || MAX_DEPTH)

    new_body = body.split("\n").map do |line|
      line.gsub(@tag_regexp) do |w|
        include_env = env.merge({
          "PATH_INFO"      => $2 ,
          "QUERY_STRING"   => "",
          "REQUEST_METHOD" => "GET",
          "SCRIPT_NAME"    => ""
        })
        include_env.delete("HTTP_ACCEPT_ENCODING")
        include_env.delete("REQUEST_PATH")
        include_env.delete("REQUEST_URI")

        status, headers, enumerable_body = @app.call(include_env.dup)
        inc  = process_include(include_env, join_body(enumerable_body), level + 1)

        inc ? inc : "file not found !!"
      end
    end
    new_body.join("\n")
  end

  def join_body(enumerable_body)
    parts = []
    enumerable_body.each { |part| parts << part }
    return parts.join("")
  end
end
