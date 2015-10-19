require "spec_helper"

describe Unsplash::User do

  let (:regularjoe) { "aarondev" }
  let (:photographer) { "lukechesser" }
  let (:fake) { "santa" }

  describe "#find" do

    it "returns as User object" do
      VCR.use_cassette("users") do
        @user = Unsplash::User.find(regularjoe)
      end

      expect(@user).to be_an Unsplash::User
    end

    it "errors if the user does not exist" do
      expect {
        VCR.use_cassette("users") do
          @user = Unsplash::User.find(fake)
        end
      }.to raise_error Unsplash::Error
    end
  end

  describe "#likes" do
    it "returns an array of Photos" do
      VCR.use_cassette("users", record: :new_episodes) do
        @liked = Unsplash::User.find("aaron").likes
      end

      expect(@liked).to be_an Array
      expect(@liked.size).to eq 4
    end

    it "returns empty array if the user does not have any likes" do
      VCR.use_cassette("users") do
        @liked = Unsplash::User.find(photographer).likes
      end

      expect(@liked).to be_empty
    end
  end

  describe "#photos" do

    it "returns an array of Photos" do
      VCR.use_cassette("users") do
        @photos = Unsplash::User.find(photographer).photos
      end

      expect(@photos).to be_an Array
      expect(@photos.size).to eq 8
    end

    it "returns empty array if the user does not have any photos" do
      VCR.use_cassette("users") do
        @photos = Unsplash::User.find(regularjoe).photos
      end

      expect(@photos).to be_empty
    end

    it "errors if the user does not exist" do
      expect {
        VCR.use_cassette("users") do
          @user = Unsplash::User.find(fake).photos
        end
      }.to raise_error Unsplash::Error
    end

  end


  describe "non-public scope actions" do

    describe "#current" do
      it "returns the current user" do
        stub_oauth_authorization

        VCR.use_cassette("users") do
          @user = Unsplash::User.current
        end

        expect(@user).to be_an Unsplash::User
        expect(@user.username).to eq "aarondev"
      end

      it "fails without a Bearer token" do
        expect {
          VCR.use_cassette("users", match_requests_on: [:headers, :uri]) do
            @user = Unsplash::User.current
          end
        }.to raise_error Unsplash::Error
      end
    end

    describe "#update_current" do
      it "returns the updated current user" do
        stub_oauth_authorization

        VCR.use_cassette("users", match_requests_on: [:headers, :uri]) do
          @user = Unsplash::User.update_current last_name: "Jangly"
        end

        expect(@user).to be_an Unsplash::User
        expect(@user.last_name).to eq "Jangly"
      end

      it "fails without a Bearer token" do
        expect {
          VCR.use_cassette("users", match_requests_on: [:headers, :uri]) do
            @user = Unsplash::User.update_current last_name: "Jangly"
          end
        }.to raise_error Unsplash::Error
      end
    end

  end
  
end