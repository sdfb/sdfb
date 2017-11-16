module ApiHelper
    def network_to_json
      connections = @relationships.map do |relationship|
        {
          id: relationship.id.to_s,
          type: "relationship",
          attributes: {
            altered: relationship.altered,
            end_year: relationship.end_year,
            end_year_type: relationship.end_date_type,
            source: relationship.person2_index,
            start_year: relationship.start_year,
            start_year_type: relationship.start_date_type,
            target: relationship.person1_index,
            weight: relationship.max_certainty
          }
        }
      end

      people = @people.map do |person|
        {
          id: person.id.to_s,
          type: "person",
          attributes: {
            birth_year: person.ext_birth_year,
            birth_year_type: person.birth_year_type,
            death_year: person.ext_death_year,
            death_year_type: person.death_year_type,
            odnb_id: person.odnb_id,
            gender: person.gender,
            historical_significance: person.historical_significance,
            name: person.display_name,
            groups: person.approved_group_ids
          }
        }
      end

      sources = @sources.map do |person|
        {
          id: person.id.to_s,
          type: "person",
          attributes: {
            name: person.display_name,
            groups: person.approved_group_ids
          }
        }
      end

    obj = {
      data: {
        id: @display_id,
        type: "network",
        attributes: {
          primary_people: @people.map{|p| p["id"].to_s},
          connections: connections
        }
      },
      included: people + sources,
      meta: {
        principal_investigators: SDFB::PRIMARY_INVESTIGATORS
      }
    }

  end
end
