require 'rubygems'
require 'sinatra'

set :upload_path, '/images'

get '/uploader' do
  %Q{
    <form enctype="multipart/form-data" method="post" action="/upload">
      <textarea class="ckeditor" cols="80" id="editor1" name="editor1" rows="10"></textarea>
    </form>
    <script src="/ckeditor/ckeditor.js"></script>
    <script>
      CKEDITOR.replace( 'editor1', {
				uiColor: '#14B8C4',
				toolbar: [
          ['Source', '-', 'Bold', 'Italic', 'Styles', '-', 'NumberedList', 'BulletedList', '-', 'Link', 'Unlink','-','MediaEmbed','Image','-','About']
				],
        filebrowserImageUploadUrl: '/upload?type=Images',
        filebrowserImageBrowseUrl: '/uploaded_images'
			});
    </script>
    
  }
end

post '/upload' do
  unless params[:upload] &&
    (tmpfile = params[:upload][:tempfile]) &&
    (name = params[:upload][:filename])
    return "No file selected"
  end
  # TODO: check that we have the "image" folder already there before uploading
  directory = "public#{settings.upload_path}"
  path = File.join(directory, name)
  # We're using a "while" because a plain f.write(tmpfile.read) would use 
  # as much RAM as the size of the attachment.
  # Found here : http://www.ruby-forum.com/topic/193036
  while blk = tmpfile.read(65536)
    File.open(path, "a") { |f| f.write(blk) }
  end
  %Q"<script type='text/javascript'>
        var CKEditorFuncNum = #{params[:CKEditorFuncNum]};
        window.parent.CKEDITOR.tools.callFunction( CKEditorFuncNum, '#{settings.upload_path}/#{name}' );
      </script>"
end

get '/uploaded_images' do
  @images = []
  basedir = "./public#{settings.upload_path}"
  contains = Dir.new(basedir).entries
  rejected = ['.', '..', '.DS_Store'] # ignore these filenames
  @images = contains.reject {|f| rejected.include? f }
  erb :uploaded_images, :layout=>false
end

