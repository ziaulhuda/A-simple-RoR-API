# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
admin = User.create(name: "Clark CEO", email: "ceo@clark.de", password: "12345678", role: "admin")
user = User.create(name: "Clark Developer", email: "dev@clark.de", password: "12345678", role: "user")
guest = User.create(name: "Clark Guest", email: "guest@clark.de", password: "12345678")

admin_post = Post.create(title: "Admin's post", body: "A great post", user: admin)
user_post = Post.create(title: "Developer's post", body: "Developers can post something too :).", user: user)

Comment.create(body: "Comment 1", post: admin_post, user: admin)
Comment.create(body: "Comment 2", post: admin_post, user: user)
Comment.create(body: "Comment 3", post: user_post, user: admin)
Comment.create(body: "Comment 4", post: user_post, user: user)