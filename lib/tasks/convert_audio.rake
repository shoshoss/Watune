namespace :audio do
  desc 'Convert all webm audio files in R2 to mp3'
  task convert_webm_to_mp3: :environment do
    require 'aws-sdk-s3'
    require 'open3'

    puts 'Starting audio conversion task...'

    # Cloudflare R2の設定
    Aws.config.update({
                        access_key_id: Rails.application.credentials.dig(:cloudflare, :r2_access_key_id),
                        secret_access_key: Rails.application.credentials.dig(:cloudflare, :r2_secret_access_key),
                        region: 'auto',
                        endpoint: "https://#{Rails.application.credentials.dig(:cloudflare,
                                                                               :r2_account_id)}.r2.cloudflarestorage.com"
                      })

    puts 'AWS configuration set.'

    s3 = Aws::S3::Client.new
    bucket = Rails.application.credentials.dig(:cloudflare, :r2_bucket)

    puts "Listing objects in bucket: #{bucket}"

    begin
      objects = s3.list_objects_v2(bucket:).contents
      if objects.empty?
        puts 'No objects found in bucket.'
      else
        objects.each do |obj|
          next unless obj.key.end_with?('.webm')

          puts "Processing file: #{obj.key}"

          begin
            # 一時ファイルのパスを設定
            webm_path = "/tmp/#{obj.key}"
            mp3_path = webm_path.sub('.webm', '.mp3')

            # R2からファイルをダウンロード
            puts "Downloading #{obj.key}..."
            File.open(webm_path, 'wb') do |file|
              s3.get_object(bucket:, key: obj.key) do |chunk|
                file.write(chunk)
              end
            end
            puts "Downloaded #{obj.key} to #{webm_path}"

            # ダウンロードしたファイルの存在確認
            if File.exist?(webm_path)
              puts "File exists: #{webm_path}"
            else
              puts "File does not exist: #{webm_path}"
              next
            end

            # webmをmp3に変換
            puts "Converting #{webm_path} to mp3..."
            stdout, stderr, status = Open3.capture3("ffmpeg -i #{webm_path} #{mp3_path}")
            puts "ffmpeg stdout: #{stdout}"
            puts "ffmpeg stderr: #{stderr}"
            if status.success?
              puts "Converted #{webm_path} to #{mp3_path}"

              # 変換後のファイルの存在確認
              if File.exist?(mp3_path)
                puts "MP3 file exists: #{mp3_path}"
              else
                puts "MP3 file does not exist: #{mp3_path}"
                next
              end

              # 変換後のmp3をR2にアップロード
              mp3_key = obj.key.sub('.webm', '.mp3')
              puts "Uploading #{mp3_key}..."
              s3.put_object(
                bucket:,
                key: mp3_key,
                body: File.open(mp3_path),
                content_type: 'audio/mp3' # Content-Typeを設定
              )
              puts "Uploaded #{mp3_key} to R2"
            else
              puts "Failed to convert #{obj.key}: #{stderr}"
            end
          rescue StandardError => e
            puts "Error processing #{obj.key}: #{e.message}"
          ensure
            # 一時ファイルを削除
            FileUtils.rm_f(webm_path)
            FileUtils.rm_f(mp3_path)
            puts "Cleaned up temporary files for #{obj.key}"
          end
        end
      end
    rescue Aws::S3::Errors::ServiceError => e
      puts "AWS S3 error: #{e.message}"
    rescue StandardError => e
      puts "General error: #{e.message}"
    end

    puts 'Audio conversion task completed.'
  end
end
