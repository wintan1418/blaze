require "open-uri"

namespace :tmdb do
  desc "Fetch real movie posters for every screening by searching TMDB by title"
  task refresh_posters: :environment do
    unless TmdbClient.configured?
      abort "TMDB_API_KEY is not set. Get a free key at https://www.themoviedb.org/settings/api and add it to your env."
    end

    scope = Screening.all
    updated = 0
    skipped = 0
    failed = 0

    scope.find_each do |screening|
      # Skip screenings that already have a real attached poster AND a tmdb_id
      if screening.poster.attached? && screening.tmdb_id.present?
        skipped += 1
        next
      end

      begin
        match = TmdbClient.search_movie(screening.title)
        unless match && match[:poster_path]
          puts "  ⚠️  no TMDB result for '#{screening.title}'"
          failed += 1
          next
        end

        screening.update(
          tmdb_id: match[:id],
          tmdb_poster_path: match[:poster_path]
        )

        # Attach the poster image to ActiveStorage so it's cached on the server
        url = TmdbClient.poster_url(match[:poster_path], size: "w780")
        io = URI.parse(url).open(read_timeout: 15, "User-Agent" => "BlazeCafe/1.0")
        filename = "poster-#{match[:id]}.jpg"

        # Replace existing attachment
        screening.poster.purge if screening.poster.attached?
        screening.poster.attach(io: io, filename: filename, content_type: "image/jpeg")

        puts "  ✓ #{screening.title} → TMDB ##{match[:id]}"
        updated += 1
      rescue StandardError => e
        puts "  ⚠️  #{screening.title} failed: #{e.class}: #{e.message}"
        failed += 1
      end
    end

    puts "─" * 50
    puts "TMDB refresh complete:"
    puts "  ✓ #{updated} updated"
    puts "  - #{skipped} skipped (already had TMDB poster)"
    puts "  ⚠️  #{failed} failed"
  end

  desc "Clear all TMDB cache on screenings (forces re-fetch on next refresh)"
  task clear: :environment do
    count = Screening.where.not(tmdb_id: nil).update_all(tmdb_id: nil, tmdb_poster_path: nil)
    puts "Cleared TMDB cache for #{count} screenings."
  end
end
