Deface::Override.new(
    :virtual_path => "spree/layouts/admin",
    :name => "Home",
    :insert_top => "#main-sidebar",
    :text =>
        "<ul class='nav nav-sidebar'>
          <%= tab :homes, icon: 'wrench' %>
        </ul>",
    :disabled => false)