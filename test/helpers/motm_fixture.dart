/// A Man of the Match summary as the backend sends it.
library;

Map<String, dynamic> motmSummaryJson({Map<String, dynamic>? yourVote}) => {
      "window": {
        "is_open": true,
        "opens_at": "2026-10-04T12:00:00Z",
        "closes_at": "2026-10-04T18:00:00Z",
        "has_closed": false,
      },
      "candidates": [
        {
          "player": {
            "id": 50,
            "slug": "john-doe",
            "firstname": "John",
            "lastname": "Doe",
            "avatar": null,
            "jersey_number": 9,
          },
          "team": {
            "id": 10,
            "slug": "team-a",
            "name": "Team A",
            "logo": null,
            "stadium": null,
            "country": "England",
          },
          "is_starting": true,
          "is_captain": false,
          "position": "forward",
        },
      ],
      "tally": [
        {
          "player": {
            "id": 50,
            "slug": "john-doe",
            "firstname": "John",
            "lastname": "Doe",
            "avatar": null,
            "jersey_number": 9,
          },
          "votes": 3,
        },
      ],
      "total_votes": 3,
      "your_vote": yourVote,
      "result": null,
    };
