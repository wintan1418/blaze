module MoneyHelper
  # Format integer kobo as Naira currency string.
  # Example: naira(250_000) => "₦2,500"
  def naira(kobo, show_kobo: false)
    return "₦0" if kobo.blank?
    naira = kobo.to_i / 100
    remainder = kobo.to_i % 100
    formatted = number_with_delimiter(naira)
    if show_kobo && remainder.positive?
      "₦#{formatted}.#{remainder.to_s.rjust(2, '0')}"
    else
      "₦#{formatted}"
    end
  end
end
