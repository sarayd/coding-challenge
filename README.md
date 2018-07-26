# Karuna Coding Challenge

This challenge consists of four questions, each designed to test a different skillset which we consider crucial to being part of our early-stage team. Each question should take at most an hour. This is not meant to be a whiteboard exercise or something to test your memorization skills. We want to see how you problem-solve as an engineer. Feel free to use your standard environment, tools, resources, etc. You can Google anything you'd like, use public libraries, and do all thing things you'd normally do. We only request that your submission be self-contained (use standard mechanisms such as a `package.json` or `Gemfile` to pull in external dependencies if needed), and that you don't get anyone else to help you (no asking friends for tips and write all your own code).

The four categories we're testing for are:

1. Code Quality
2. SQL
3. Architecture
4. Web

Additionally, we will ask you to submit a code sample. This should be the piece of code that you are most proud of. You could be proud of this code because of how elegant, efficient, or otherwise beautiful it is.

## Environment

The Code Quality question must be completed in Ruby (since this is the language the majority of our backend systems are currently written in). If you're unfamiliar with Ruby, check out this [migration guide](https://www.ruby-lang.org/en/documentation/ruby-from-other-languages/). Hopefully you don't feel too hindered by this restriction - feel free to include a note if you found it particularly annoying, or to let us know that you're strongest with another language.

The SQL question is run against an up-to-date Postgres instance.

The Architecture is completely open-ended.

The Web question can use any sane frontend/backend setup you wish (including a simple static HTML file). We recommend keeping it simple and not using a module bundler. We will run your code in a modern version of Chrome, unless you tell us to do something else.

## Submission

Please use the following procedure to submit your response to this challenge. While the repository is shared, your submission will be encrypted, and your commit will be anonymous.

1. Clone this repo
2. Run [`new_submission.sh`](scripts/new_submission.sh) to generate a directory for your submission
3. Place your submissions for each question in the relevant sub-directory
4. Run [`finalize_submission.sh`](scripts/finalize_submission.sh) to encrypt your submission, commit it, and push it to a new branch
5. Email us and let us know you have submitted!

If you need up update your submission, please use [`amend_submission.sh`](scripts/amend_submission.sh). If it doesn't exist, you'll need to first create a `.id` file with your Submission ID.

## Questions

### Code Quality

Design a class that allows for rate-limiting of arbitrary code blocks. Initially, assume there is only one thread using an instance of the class at a time, and that any state can be stored internally and locally. You are free to choose any sane rate-limiting algorithm. Please include a test file (or modify the [existing one](template/code_quality/test_rate_limiter.rb)) to demonstrate the efficacy of your class. Do not worry about writing particularly performant code; the focus should be on correctness and code quality.

If you have time, feel free to add creative extensions, such as thread-safety, per-instance default options, shared remote state in a database, alternative rate-limiting schemes, or improving runtime/memory performance. This is strictly optional.

The class should be called `RateLimiter`, and it should have a single public method, `limit`. The initializer should accept a hash of options that include at least `throws`, and `limit` should take a `name`, `threshold`, and `period`. This is demonstrated below.

If `throws` is `true`, the block should raise a `RateLimiter::Limited` error when the number of calls exceeds the `threshold` for a given `period`. If `throws` is `false`, the block should simply not execute, instead of throwing an error.

You may assume that there is a maximum to the length of any `period` of `10.minutes`. Please document this or any other assumptions clearly.

```ruby
class RateLimitTester
  def initialize
    @limiter = RateLimiter.new(throws: true)
  end

  def expensive_foo!
    @limiter.limit(:expensive_foo, threshold: 3, period: 1.minute) do
      sleep 1
    end
  end
end

tester = RateLimitTester.new
3.times { tester.expensive_foo! }
tester.expensive_foo! # should raise RateLimiter::Limited
```

### SQL

We are attempting to build a service which receives messages to be sent, and queues them locally so that they can be delivered to the recipient one at a time. Messages have a `medium` (such as "SMS") and an `identifier` (such as "+12345678900"), which together uniquely identify a recipient. The external service we use to send messages alerts us when a message has been delivered, so that the next message for a recipient (if any) can be sent out.

We wish to write a query that gives us the messages which are eligible to be sent at the given moment. It should preserve the ordering of messages, and ensure a message is only sent after the previous message for a recipient is delivered. This means we want to return, per recipient, the _earliest_ pending message, assuming there are no messages currently in-flight for that recipient. If there are any messages in-flight for that recipient, we want to return nothing.

Assume you have a table created with the following schema.

```sql
CREATE TABLE messages (
  id integer PRIMARY KEY,
  medium character varying NOT NULL,
  identifier character varying NOT NULL,
  status integer NOT NULL,
  body text NOT NULL,
  created_at timestamp without time zone NOT NULL
);
```

`status` is an enum, with the following value map.

```ruby
{
  0: :pending,
  1: :inflight,
  2: :succeeded,
}
```

Write a single query ([CTE](https://www.postgresql.org/docs/9.1/static/queries-with.html)s are allowed) which returns all rows `r` that satisfy the following:

- `r.status` is `pending`
- there are no rows with the same `(medium, identifier)` as `r` that are also `pending` but have an earlier `created_at` (this ensures the returned row is the earliest pending message for the recipient)
- there are no rows with the same `(medium, identifier)` as `r` that are `inflight`

If it helps, the formal definition of the set `R` of returned rows are as follows. Here, `U` is the set of all records in the database, and `M_r` is the set of records that have the same `medium` and `identifier` as a record `r`.

![formal definition of R](images/sql.png)


```tex
M_r := \{r' \in U \setminus \{r\} : r'.\text{medium} = r.\text{medium} \land r'.\text{source} = r.\text{source}\}

R := \{r \in U : r.\text{status} = \text{``pending''} \land (\nexists r' \in M_r)\left[r'.\text{created\_at} < r.\text{created\_at} \lor r'.\text{status} = \text{``inflight''}\right]\}
```

### Messaging Platform

#### Architecture

We would like to design a system (or series of systems) which allows for our care coordinators to have a unified messaging platform with which to message patients. The requirements of the system are:

1. Patients can message Karuna from various different mediums (Facebook Messenger, SMS, etc.)
2. The same patient can contact us on different mediums at different times, and receive responses on the last medium they used
3. Messages from patients can get routed to the correct coordinator, based on a set of rules
4. Coordinators have a UI which shows all their routed messages in one place
5. Coordinators can respond to messages without worrying about which medium will be used
6. Coordinators can "hand off" a patient to another coordinator
7. Audio and video interactions are recorded and transcribed
8. Both incoming and outgoing messages are delivered in-order and exactly-once
9. The external systems for delivering messages can be easily changed
10. Various metrics (such as the maximum time a patient waits for a response) can be reported and alerted on

This is intentionally a very open-ended question. There are hundreds of different aspects you can think through, from the data models, to the interactions between microservices (if indeed there are any), to the external APIs used for delivery. We are not asking you to cover every possible question - just the ones you think are most important.

Your deliverable has two pieces. The first is a defining set of questions: what are the most important aspects of this system to think through? We will use this to learn how you approach ambiguity, and how you bring structure to new problems. The second piece is to answer all your own questions, to whatever degree of thoroughness you deem necessary. Please do not spend more than an hour on this question. You are free to make this question as technical or visual as you wish. We're not looking for the "right" answer, just an example of how you form and communicate plans.

#### Frontend

// build a react app that displays conversations, marks them as read, shows messages, allows sending, and shows profile. mock the data locally, fetch the message values from API provided (deterministic based on name)

#### Design

// mockups for the frontend


### Creative Web

This one is fun! Please include your solution to the following.

> What is the most creative way you can get a circle to appear on the screen of a web browser?

Please include a run script (`run.sh`) which we can run to test your solution. This script should do any necessary building and compilation, and print either an address or a file we can open in a web browser running on the same machine.

// list all of them

### `bf`

#### Backend

// write a bf interpreter as a class with an API (ruby). if you're full-stack, make it an API and do the next one too

#### Execution Visualizer

// web app that gives input box for bf script, and api that you send it to, get a token, and then can increment one step at a time and get the tapes. visualize the tapes and how they change

### Code Sample

Please include with it a brief description of what your code does, and why you're so proud of it.
