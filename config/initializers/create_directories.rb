kor_dirs = []

kor_dirs << "data/downloads"
kor_dirs << "tmp/stills"

kor_dirs.each do |d|
  FileUtils.mkdir_p "#{Rails.root}/#{d}"
end
