#!/bin/bash
echo "Cleaning Quarto output and all caches..."
rm -rf _site _freeze .quarto
rm -rf index_cache news_cache publications_cache team_cache research_cache opportunities_cache contact_cache
rm -rf index_files news_files publications_files
echo "Done. Now run: quarto preview"
