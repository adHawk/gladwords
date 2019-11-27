# Gladwords

A saner Ruby wrapper over the AdWords API, using [ROM.rb](https://rom-rb.org).

# Clout

[![CircleCI](https://circleci.com/gh/adHawk/gladwords.svg?style=svg)](https://circleci.com/gh/adHawk/gladwords)

## Usage

```ruby
# setup your client following these instructions:
#   https://github.com/googleads/google-api-ads-ruby/blob/master/adwords_api/README.md#2---using-the-client-library
client = AdwordsApi::Api.new

ROM::Configuration.new(:adwords, client: client) do |config|
  config.relation(:campaigns) do
    auto_struct(true)
    auto_map(true)

    schema(infer: true) do
      attribute :id, Gladwords::Types::ID

      primary_key :id

      associations do
        has_many :ad_groups, combine_key: :campaign_id
      end
    end
  end

  config.relation(:ad_groups) do
    auto_struct(true)
    auto_map(true)

    schema(infer: true) do
      attribute :id, Gladwords::Types::ID

      primary_key :id

      associations do
        belongs_to :campaign, combine_key: :id
      end
    end
  end
end

scope = subject.select(:id, :name).where(name: 'Test Campaign 2')
gladwords = ROM.container(configuration)

# query the relations
campaigns = gladwords.relations[:campaigns]
campaigns.select(:id, :name).where(name: 'Campaign 2').to_a # [{ id: '123', name: 'Campaign 2']]
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'attr-gather'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install attr-gather

