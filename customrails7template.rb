run "if uname | grep -q 'Darwin'; then pgrep spring | xargs kill -9; fi"

# Gemfile
########################################
inject_into_file "Gemfile", before: "group :development, :test do" do
  <<~RUBY
    gem "devise"
    gem "autoprefixer-rails"
    gem "font-awesome-sass", "~> 6.1"
    gem "simple_form", github: "heartcombo/simple_form"
  RUBY
end

inject_into_file "Gemfile", after: 'gem "debug", platforms: %i[ mri mingw x64_mingw ]' do
<<-RUBY

  gem "dotenv-rails"
RUBY
end

gsub_file("Gemfile", '# gem "sassc-rails"', 'gem "sassc-rails"')

# Assets
########################################
run "rm -rf app/assets/stylesheets"
run "rm -rf vendor"
run "curl -L https://github.com/Jrps9/stylesheets/raw/main/stylesheets.zip > customstylesheets.zip"
run "unzip customstylesheets.zip -d app/assets && rm -f customstylesheets.zip"

run "mv app/assets/rails-stylesheets-master app/assets/stylesheets"

folder "app/assets/images", <<~RUBY
  run "curl -L https://github.com/Jrps9/stylesheets/raw/main/images/logo_transparent.png"
  run "curl -L https://github.com/Jrps9/stylesheets/raw/main/images/background-contact.jpg"
RUBY

inject_into_file "config/initializers/assets.rb", before: "# Precompile additional assets." do
  <<~RUBY
    Rails.application.config.assets.paths << Rails.root.join("node_modules")
  RUBY
end

# Layout
########################################

gsub_file(
  "app/views/layouts/application.html.erb",
  '<meta name="viewport" content="width=device-width,initial-scale=1">',
  '<meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">'
)

# Flashes
########################################
file "app/views/shared/_flashes.html.erb", <<~HTML
  <% if notice %>
    <div class="alert alert-info alert-dismissible fade show m-1" role="alert">
      <%= notice %>
      <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close">
      </button>
    </div>
  <% end %>
  <% if alert %>
    <div class="alert alert-warning alert-dismissible fade show m-1" role="alert">
      <%= alert %>
      <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close">
      </button>
    </div>
  <% end %>
HTML

file "app/views/shared/_navbar.html.erb", <<~HTML
  <div class="navbar-deSerie">
    <div class="navbar-deSerie__logo">
      <%= link_to "#" do %>
      <% end %>
    </div>
    <ul class="navbar-deSerie__links">
      <li class="navbar-deSerie__link">
        <%= link_to "Home", root_path %>
      </li>
      <li class="navbar-deSerie__link">
        <%= link_to "Gallery", '#' %>
      </li>
      <li class="navbar-deSerie__link">
        <%= link_to "About", '#' %>
      </li>
      <li class="navbar-deSerie__link">
        <%= link_to "Contact", 'contact' %>
      </li>
      <% if user_signed_in? %>
        <li class="navbar-deSerie__link">
          <%= link_to "Log out", destroy_user_session_path, method: :delete %>
        </li>
      <% else %>
        <li class="navbar-deSerie__link">
          <%= link_to "Login", new_user_session_path %>
        </li>
      <% end %>
    </ul>
  </div>

  <div class="navbar-deSerie__burger">
    <span class="navbar-deSerie__burger__span s--1"></span>
    <span class="navbar-deSerie__burger__span s--2"></span>
    <span class="navbar-deSerie__burger__span s--3"></span>
  </div>
HTML

file "app/views/shared/_footer.html.erb", <<~HTML
  <div class="footer-deSerie">
    <div class="footer-deSerie__logo">
      <%= link_to "#" do %>
      <% end %>
    </div>

    <span class="vertical-line"></span>

    <div class="footer-deSerie__contact">
      <p>Tel : 06 52 84 03 18</p>
      <p>E-mail: contact@naut-society.fr</p>
    </div>

    <span class="vertical-line"></span>

    <div class="footer-deSerie__sitemap">
      <p>Plan du site</p>
      <p>Mentions légales</p>
    </div>

    <span class="vertical-line"></span>

    <div class="footer-deSerie__social-network">
      <%= link_to "#", class: "social-link" do %>
        <i class="fa-brands fa-instagram"></i>
      <% end %>
      <%= link_to "#", class: "social-link" do %>
        <i class="fa-brands fa-facebook-f"></i>
      <% end %>
      <%= link_to "#", class: "social-link" do %>
        <i class="fa-brands fa-twitter"></i>
      <% end %>
    </div>
  </div>
HTML

inject_into_file "app/views/layouts/application.html.erb", after: "<body>" do
  <<~HTML
    <div class="page">
      <% if action_name != "contact" %>
        <%= render "shared/navbar" %>
      <% end %>
      <%= render "shared/flashes" %>
      <%= yield %>
    </div>
    <% if action_name != "contact" %>
      <%= render "shared/footer" %>
    <% end %>
  HTML
end

# README
########################################
markdown_file_content = <<~MARKDOWN
  Rails app generated with [lewagon/rails-templates](https://github.com/lewagon/rails-templates), created by the [Le Wagon coding bootcamp](https://www.lewagon.com) team and customized by Jrps9.
MARKDOWN
file "README.md", markdown_file_content, force: true

# Generators
########################################
generators = <<~RUBY
  config.generators do |generate|
    generate.assets false
    generate.helper false
    generate.test_framework :test_unit, fixture: false
  end
RUBY

environment generators

########################################
# After bundle
########################################
after_bundle do
  # Generators: db + simple form + pages controller
  ########################################
  rails_command "db:drop db:create db:migrate"
  generate("simple_form:install", "--bootstrap")
  generate(:controller, "pages", "home", "contact", "--skip-routes", "--no-test-framework")

  # Routes
  ########################################
  route 'root to: "pages#home"'
  route 'get "contact", to: "pages#contact"'
  # Contact
  ########################################
  file "app/views/pages/contact.html.erb", <<~HTML
    <div class="row no-pad">
      <div class="col-12 col-md-6 col-lg-5">
        <div class="contact__container">
          <%= render "shared/contact" %>
        </div>
      </div>
      <div class="col-12 col-md-6 col-lg-7 contact__background">
        <%= image_tag("background-contact.jpg") %>
        <div class="contact__background--text">
          <h2>Vous avez un projet ?</h2>
          <h2>Nous serions heureux d'en parler !</h2>
        </div>
      </div>
    </div>
  HTML

  create_file "app/views/shared/_contact.html.erb", <<~HTML
  <%= simple_form_for "toto", defaults: { input_html:{class: "custom-form-field"}, wrapper_html:{ class: "custom-input"}, label_html: {class: "custom-form-label"}} do |f| %>
    <%= link_to root_path, class:"contact__link" do %>
      <p><i class="fa-solid fa-circle-arrow-left"></i> Retour à l'acceuil</p>
    <% end %>
    <h1>Comuniquons !</h1>
    <p>Des suggestions, remarques, ou questions ?</p>
    <br>
    <%= f.input :name,
    label:"Nom ",
    placeholder: "Votre nom ou prénom",
    required: true %>
    <%= f.input :email, label:"E-mail", required: true, placeholder: "Votre e-mail" %>
    <%= f.label :Message, class:"custom-form-label" %>
    <%= f.text_area :message, rows: 8, cols: 40, required: true, class: "custom-form-field",
          placeholder: "Votre message..."%>
    <%= f.submit 'Envoyer', class: 'custom-contact-submit' %>
  <% end %>
  HTML

  # Gitignore
  ########################################
  append_file ".gitignore", <<~TXT
    # Ignore .env file containing credentials.
    .env*
    # Ignore Mac and Linux file system files
    *.swp
    .DS_Store
  TXT

  # Devise install + user
  ########################################
  generate("devise:install")
  generate("devise", "User")

  # Application controller
  ########################################
  run "rm app/controllers/application_controller.rb"
  file "app/controllers/application_controller.rb", <<~RUBY
    class ApplicationController < ActionController::Base
      before_action :authenticate_user!
    end
  RUBY

  # migrate + devise views
  ########################################
  rails_command "db:migrate"
  generate("devise:views")
  gsub_file(
    "app/views/devise/registrations/new.html.erb",
    "<%= simple_form_for(resource, as: resource_name, url: registration_path(resource_name)) do |f| %>",
    "<%= simple_form_for(resource, as: resource_name, url: registration_path(resource_name), data: { turbo: :false }) do |f| %>"
  )
  gsub_file(
    "app/views/devise/sessions/new.html.erb",
    "<%= simple_form_for(resource, as: resource_name, url: session_path(resource_name)) do |f| %>",
    "<%= simple_form_for(resource, as: resource_name, url: session_path(resource_name), data: { turbo: :false }) do |f| %>"
  )
  link_to = <<~HTML
    <p>Unhappy? <%= link_to "Cancel my account", registration_path(resource_name), data: { confirm: "Are you sure?" }, method: :delete %></p>
  HTML
  button_to = <<~HTML
    <div class="d-flex align-items-center">
      <div>Unhappy?</div>
      <%= button_to "Cancel my account", registration_path(resource_name), data: { confirm: "Are you sure?" }, method: :delete, class: "btn btn-link" %>
    </div>
  HTML
  gsub_file("app/views/devise/registrations/edit.html.erb", link_to, button_to)

  # Pages Controller
  ########################################
  run "rm app/controllers/pages_controller.rb"
  file "app/controllers/pages_controller.rb", <<~RUBY
    class PagesController < ApplicationController
      skip_before_action :authenticate_user!, only: [ :home ]

      def home
      end
    end
  RUBY

  # Environments
  ########################################
  environment 'config.action_mailer.default_url_options = { host: "http://localhost:3000" }', env: "development"
  environment 'config.action_mailer.default_url_options = { host: "http://TODO_PUT_YOUR_DOMAIN_HERE" }', env: "production"

  # Yarn
  ########################################
  run "yarn add bootstrap @popperjs/core"
  append_file "app/javascript/packs/application.js", <<~JS
    import "bootstrap"
  JS

  # Heroku
  ########################################
  run "bundle lock --add-platform x86_64-linux"

  # Dotenv
  ########################################
  run "touch '.env'"

  # Rubocop
  ########################################
  run "curl -L https://raw.githubusercontent.com/lewagon/rails-templates/master/.rubocop.yml > .rubocop.yml"

  # Git
  ########################################
  git :init
  git add: "."
  git commit: "-m 'Initial commit with devise template, customized front by Jrps9, from https://github.com/lewagon/rails-templates'"
end
