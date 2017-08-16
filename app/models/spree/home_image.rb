class Spree::HomeImage < Spree::Base

	validate :no_attachment_errors

	has_attached_file :attachment,
										styles: { mini: '128x128>', web_carousel: '1900x541#', carousel: '750x422#', taxon: '128x128#', top_banner: '750x172#' },
										default_style: :mini,
										url: '/spree/products/:id/:style/:basename.:extension',
										path: ':rails_root/public/spree/products/:id/:style/:basename.:extension',
										convert_options: { all: '-strip -auto-orient -colorspace sRGB' }
	validates_attachment :attachment,
		presence: true,
		content_type: { content_type: %w(image/jpeg image/jpg image/png image/gif) }

	belongs_to :home_item	

    # if there are errors from the plugin, then add a more meaningful message
	def no_attachment_errors
		unless attachment.errors.empty?
			# uncomment this to get rid of the less-than-useful interim messages
			# errors.clear
			errors.add :attachment, "Paperclip returned errors for file '#{attachment_file_name}' - check ImageMagick installation or image source file."
			false
		end
	end
end
