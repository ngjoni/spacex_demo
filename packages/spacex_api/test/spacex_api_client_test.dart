import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:spacex_api/spacex_api.dart';
import 'package:test/test.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  late Uri rocketUri;
  late Uri crewUri;
  late Uri latestLaunchUri;

  group('SpaceXApiClient', () {
    late http.Client httpClient;
    late SpaceXApiClient subject;

    final date = DateTime.now();

    final rockets = List.generate(
      3,
      (i) => Rocket(
          id: '$i',
          name: 'mock-rocket-name-$i',
          description: 'mock-rocket-description-$i',
          height: const Length(meters: 1, feet: 1),
          diameter: const Length(meters: 1, feet: 1),
          mass: const Mass(kg: 1, lb: 1),
          firstFlight: DateTime.now()),
    );

    final crewMembers = List.generate(
      3,
      (i) => CrewMember(
        id: '$i',
        name: 'Alejandro Ferrero',
        status: 'active',
        agency: 'Very Good Aliens',
        image:
            'https://media-exp1.licdn.com/dms/image/C4D03AQHVNIVOMkwQaA/profile-displayphoto-shrink_200_200/0/1631637257882?e=1637193600&v=beta&t=jFm-Ckb0KS0Z5hJDbo3ZBSEZSYLHfllUf4N-IV2NDTc',
        wikipedia: 'https://www.wikipedia.org/',
        launches: ['Launch $i'],
      ),
    );

    final latestLaunch = Launch(
      id: '1337',
      name: 'mock-launch-name-1337',
      dateLocal: date,
      dateUtc: date,
      links: const Links(
          patch: Patch(
              small: 'https://avatars.githubusercontent.com/u/2918581?v=4'),
          webcast: 'https://www.youtube.com',
          wikipedia: 'https://www.wikipedia.org/'),
    );

    setUp(() {
      httpClient = MockHttpClient();
      subject = SpaceXApiClient(httpClient: httpClient);
      rocketUri = Uri.https(SpaceXApiClient.authority, '/v4/rockets');
      crewUri = Uri.https(SpaceXApiClient.authority, '/v4/crew');
      latestLaunchUri =
          Uri.https(SpaceXApiClient.authority, '/v4/launches/latest/');
    });

    test('constructor returns normally', () {
      expect(
        () => SpaceXApiClient(),
        returnsNormally,
      );
    });

    group('.fetchAllRockets', () {
      setUp(() {
        when(() => httpClient.get(rocketUri)).thenAnswer(
          (_) async => http.Response(json.encode(rockets), 200),
        );
      });

      test('throws HttpException when http client throws exception', () {
        when(() => httpClient.get(rocketUri)).thenThrow(Exception());

        expect(
          () => subject.fetchAllRockets(),
          throwsA(isA<HttpException>()),
        );
      });

      test(
        'throws HttpRequestFailure when response status code is not 200',
        () {
          when(() => httpClient.get(rocketUri)).thenAnswer(
            (_) async => http.Response('', 400),
          );

          expect(
            () => subject.fetchAllRockets(),
            throwsA(
              isA<HttpRequestFailure>()
                  .having((error) => error.statusCode, 'statusCode', 400),
            ),
          );
        },
      );

      test(
        'throws JsonDecodeException when decoding response fails',
        () {
          when(() => httpClient.get(rocketUri)).thenAnswer(
            (_) async => http.Response('definitely not json!', 200),
          );

          expect(
            () => subject.fetchAllRockets(),
            throwsA(isA<JsonDecodeException>()),
          );
        },
      );

      test(
        'throws JsonDeserializationException '
        'when deserializing json body fails',
        () async {
          when(() => httpClient.get(rocketUri)).thenAnswer(
            (_) async => http.Response(
              '[{"this_is_not_a_rocket_doc": true}]',
              200,
            ),
          );

          expect(
            () => subject.fetchAllRockets(),
            throwsA(isA<JsonDeserializationException>()),
          );
        },
      );

      test('makes correct request', () async {
        await subject.fetchAllRockets();

        verify(
          () => httpClient.get(rocketUri),
        ).called(1);
      });

      test('returns correct list of rockets', () {
        expect(
          subject.fetchAllRockets(),
          completion(equals(rockets)),
        );
      });
    });

    group('.fetchAllCrewMembers', () {
      setUp(() {
        when(() => httpClient.get(crewUri)).thenAnswer(
          (_) async => http.Response(json.encode(crewMembers), 200),
        );
      });

      test('throws HttpException when http client throws exception', () {
        when(() => httpClient.get(crewUri)).thenThrow(Exception());

        expect(
          () => subject.fetchAllRockets(),
          throwsA(isA<HttpException>()),
        );
      });

      test(
        'throws HttpRequestFailure when response status code is not 200',
        () {
          when(() => httpClient.get(crewUri)).thenAnswer(
            (_) async => http.Response('', 400),
          );

          expect(
            () => subject.fetchAllCrewMembers(),
            throwsA(
              isA<HttpRequestFailure>()
                  .having((error) => error.statusCode, 'statusCode', 400),
            ),
          );
        },
      );

      test(
        'throws JsonDecodeException when decoding response fails',
        () {
          when(() => httpClient.get(crewUri)).thenAnswer(
            (_) async => http.Response('definitely not json!', 200),
          );

          expect(
            () => subject.fetchAllCrewMembers(),
            throwsA(isA<JsonDecodeException>()),
          );
        },
      );

      test(
        'throws JsonDeserializationException '
        'when deserializing json body fails',
        () {
          when(() => httpClient.get(crewUri)).thenAnswer(
            (_) async => http.Response(
              '[{"this_is_not_a_crew_doc": true}]',
              200,
            ),
          );

          expect(
            () => subject.fetchAllCrewMembers(),
            throwsA(isA<JsonDeserializationException>()),
          );
        },
      );

      test('makes correct request', () async {
        await subject.fetchAllCrewMembers();

        verify(
          () => httpClient.get(crewUri),
        ).called(1);
      });

      test('returns correct list of crew members', () {
        expect(
          subject.fetchAllCrewMembers(),
          completion(equals(crewMembers)),
        );
      });
    });

    group('.fetchLatestLaunch', () {
      setUp(() {
        when(() => httpClient.get(latestLaunchUri)).thenAnswer(
          (_) async => http.Response(json.encode(latestLaunch), 200),
        );
      });

      test('throws HttpException when http client throws exception', () {
        when(() => httpClient.get(latestLaunchUri)).thenThrow(Exception());

        expect(
          () => subject.fetchLatestLaunch(),
          throwsA(isA<HttpException>()),
        );
      });

      test(
        'throws HttpRequestFailure when response status code is not 200',
        () {
          when(() => httpClient.get(latestLaunchUri)).thenAnswer(
            (_) async => http.Response('', 400),
          );

          expect(
            () => subject.fetchLatestLaunch(),
            throwsA(
              isA<HttpRequestFailure>()
                  .having((error) => error.statusCode, 'statusCode', 400),
            ),
          );
        },
      );

      test(
        'throws JsonDecodeException when decoding response fails',
        () {
          when(() => httpClient.get(latestLaunchUri)).thenAnswer(
            (_) async => http.Response('definitely not json!', 200),
          );

          expect(
            () => subject.fetchLatestLaunch(),
            throwsA(isA<JsonDecodeException>()),
          );
        },
      );

      test(
        'throws JsonDeserializationException '
        'when deserializing json body fails',
        () {
          when(() => httpClient.get(latestLaunchUri)).thenAnswer(
            (_) async => http.Response(
              '{"this_is_not_the_latest_launch": true}',
              200,
            ),
          );

          expect(
            () => subject.fetchLatestLaunch(),
            throwsA(isA<JsonDeserializationException>()),
          );
        },
      );

      test('makes correct request', () async {
        await subject.fetchLatestLaunch();

        verify(
          () => httpClient.get(latestLaunchUri),
        ).called(1);
      });

      test('returns correct element of the latest launch', () {
        expect(
          subject.fetchLatestLaunch(),
          completion(equals(latestLaunch)),
        );
      });
    });
  });
}
