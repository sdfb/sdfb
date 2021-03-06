module SDFB
  FRANCIS_BACON       = 10000473

  DATE_TYPES          = ["BF","AF","IN","CA","BF/IN","AF/IN","NA"]
  EARLIEST_YEAR       = 1500
  LATEST_YEAR         = 1700
  EARLIEST_BIRTH_YEAR = EARLIEST_YEAR - 100
  LATEST_DEATH_YEAR   = LATEST_YEAR + 100

  PRIMARY_INVESTIGATORS = [ "Daniel Shore", "Chris Warren", "Jessica Otis"]

  DEFAULT_CONFIDENCE = 60

  GENDER_LIST    = ["female", "male", "gender_nonconforming"]
  USER_TYPES_LIST = ["Standard", "Curator", "Admin"]
end
