CREATE RULE morpher_duplicate_ignore AS ON INSERT TO morpher
  WHERE EXISTS(SELECT 1 FROM morpher WHERE src=NEW.src)
  DO INSTEAD NOTHING;
