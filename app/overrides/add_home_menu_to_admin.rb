Deface::Override.new(
    :virtual_path => "spree/layouts/admin",
    :name => "Home",
    :insert_top => "#main-sidebar",
    :text =>
        "<ul class='nav nav-sidebar'>
          <%= tab I18n.t('home_menu'),url: spree.admin_homes_path, icon: 'wrench' %>
        </ul>",
    :disabled => false)