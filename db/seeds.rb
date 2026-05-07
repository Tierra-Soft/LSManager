# Initial admin
admin = Admin.find_or_create_by!(email: "admin@example.com") do |a|
  a.name = "システム管理者"
  a.password = "password123"
  a.role = :super_admin
end
puts "Admin created: #{admin.email}"

# Sample courses
course1 = Course.find_or_create_by!(title: "Rubyプログラミング基礎") do |c|
  c.description = "Rubyの基本文法からオブジェクト指向まで学びます。"
  c.status = :published
end

course2 = Course.find_or_create_by!(title: "Webアプリケーション開発") do |c|
  c.description = "Ruby on Railsを使ったWebアプリケーション開発を学びます。"
  c.status = :published
end

# Lessons for course1
[
  { title: "Ruby環境構築", position: 1 },
  { title: "基本文法（変数・条件分岐）", position: 2 },
  { title: "配列とハッシュ", position: 3 },
  { title: "メソッドとブロック", position: 4 },
  { title: "クラスとオブジェクト指向", position: 5 }
].each do |attrs|
  course1.lessons.find_or_create_by!(title: attrs[:title]) { |l| l.position = attrs[:position] }
end

# Lessons for course2
[
  { title: "Rails入門", position: 1 },
  { title: "MVCアーキテクチャ", position: 2 },
  { title: "データベースとマイグレーション", position: 3 },
  { title: "ルーティングとコントローラ", position: 4 },
  { title: "ビューとフォーム", position: 5 }
].each do |attrs|
  course2.lessons.find_or_create_by!(title: attrs[:title]) { |l| l.position = attrs[:position] }
end

# Sample students
[
  { student_code: "S001", name: "田中 太郎", email: "tanaka@example.com", department: "営業部", enrolled_on: "2026-04-01" },
  { student_code: "S002", name: "鈴木 花子", email: "suzuki@example.com", department: "技術部", enrolled_on: "2026-04-01" },
  { student_code: "S003", name: "佐藤 次郎", email: "sato@example.com", department: "人事部", enrolled_on: "2026-04-01" }
].each do |attrs|
  Student.find_or_create_by!(email: attrs[:email]) { |s| s.assign_attributes(attrs.merge(status: :active)) }
end

# Email templates
EmailTemplate.find_or_create_by!(name: "ウェルカムメール") do |t|
  t.subject = "【LSManager】ご入学おめでとうございます、{{name}} 様"
  t.body = "{{name}} 様\n\nこの度はセルフラーニングプログラムにご参加いただき誠にありがとうございます。\n\n学籍番号: {{student_code}}\n所属部署: {{department}}\n\nまずはシステムにログインし、コース一覧をご確認ください。\n\nご不明な点がございましたら、管理者までお問い合わせください。\n\nよろしくお願いいたします。"
  t.category = :welcome
end

EmailTemplate.find_or_create_by!(name: "学習進捗リマインダー") do |t|
  t.subject = "【LSManager】学習の進捗確認のご案内、{{name}} 様"
  t.body = "{{name}} 様\n\nお世話になっております。\n\n学習進捗の確認ご案内をお送りしております。\n現在の学習状況をシステムよりご確認ください。\n\n引き続き学習を継続していただきますよう、よろしくお願いいたします。"
  t.category = :progress_reminder
end

EmailTemplate.find_or_create_by!(name: "修了おめでとうございます") do |t|
  t.subject = "【LSManager】コース修了おめでとうございます！{{name}} 様"
  t.body = "{{name}} 様\n\nこの度はコースを修了されましたことを心よりお祝い申し上げます。\n\n学習を通じて身につけた知識・スキルを、ぜひ実務に活かしていただければ幸いです。\n\n今後もさらなる学習への挑戦をお待ちしております。"
  t.category = :completion
end

puts "Seed data created successfully!"
