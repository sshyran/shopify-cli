# frozen_string_literal: true
require "project_types/theme/test_helper"

module Theme
  module Commands
    class PullTest < MiniTest::Test
      include TestHelpers::FakeUI

      def setup
        super

        @ctx = ShopifyCLI::Context.new
        @command = Theme::Command::Pull.new(@ctx)

        @theme = stub(
          "Theme",
          id: 1234,
          name: "Test theme",
          shop: "test.myshopify.io",
        )
        @syncer = stub("Syncer", lock_io!: nil, unlock_io!: nil)
        @ignore_filter = mock("IgnoreFilter")
        @query_filter = mock("QueryFilter")

        ShopifyCLI::Theme::IgnoreFilter.stubs(:from_path).with(".").returns(@ignore_filter)
        ShopifyCLI::Theme::QueryFilter.stubs(:new).returns(@query_filter)
      end

      def test_pull_theme
        ShopifyCLI::Theme::Theme.expects(:new)
          .with(@ctx, root: ".", id: 1234)
          .returns(@theme)

        ShopifyCLI::Theme::Syncer.expects(:new)
          .with(@ctx, theme: @theme, query_filter: @query_filter, ignore_filter: @ignore_filter)
          .returns(@syncer)

        @syncer.expects(:start_threads)
        @syncer.expects(:shutdown)

        @syncer.expects(:download_theme!).with(delete: true)
        @ctx.expects(:done)

        @command.options.flags[:theme_id] = 1234
        @command.call([], "pull")
      end

      def test_pull_live_theme
        ShopifyCLI::Theme::Theme.expects(:live)
          .with(@ctx, root: ".")
          .returns(@theme)

        ShopifyCLI::Theme::Syncer.expects(:new)
          .with(@ctx, theme: @theme, query_filter: @query_filter, ignore_filter: @ignore_filter)
          .returns(@syncer)

        @syncer.expects(:start_threads)
        @syncer.expects(:shutdown)

        @syncer.expects(:download_theme!).with(delete: true)
        @ctx.expects(:done)

        @command.options.flags[:live] = true
        @command.call([], "pull")
      end

      def test_pull_pass_nodelete_to_syncer
        ShopifyCLI::Theme::Theme.expects(:new)
          .with(@ctx, root: ".", id: 1234)
          .returns(@theme)

        ShopifyCLI::Theme::Syncer.expects(:new)
          .with(@ctx, theme: @theme, query_filter: @query_filter, ignore_filter: @ignore_filter)
          .returns(@syncer)

        @syncer.expects(:start_threads)
        @syncer.expects(:shutdown)

        @syncer.expects(:download_theme!).with(delete: false)

        @ctx.expects(:done)

        @command.options.flags[:theme_id] = 1234
        @command.options.flags[:nodelete] = true
        @command.call([], "pull")
      end

      def test_pull_with_query
        query = "config/*"
        query_filter = mock("QueryFilter")

        ShopifyCLI::Theme::Theme.expects(:new)
          .with(@ctx, root: ".", id: 1234)
          .returns(@theme)
        ShopifyCLI::Theme::QueryFilter.expects(:new)
          .with(query)
          .returns(query_filter)
        ShopifyCLI::Theme::Syncer.expects(:new)
          .with(@ctx, theme: @theme, query_filter: query_filter, ignore_filter: @ignore_filter)
          .returns(@syncer)

        @syncer.expects(:start_threads)
        @syncer.expects(:shutdown)

        @syncer.expects(:download_theme!).with(delete: true)
        @ctx.expects(:done)

        @command.options.flags[:theme_id] = 1234
        @command.options.flags[:query] = query
        @command.call([], "pull")
      end

      def test_pull_with_ignores
        ShopifyCLI::Theme::Theme.expects(:new)
          .with(@ctx, root: ".", id: 1234)
          .returns(@theme)

        @ignore_filter.expects(:add_patterns).with(["config/*"])

        ShopifyCLI::Theme::IgnoreFilter.expects(:from_path)
          .with(".")
          .returns(@ignore_filter)
        ShopifyCLI::Theme::Syncer.expects(:new)
          .with(@ctx, theme: @theme, query_filter: @query_filter, ignore_filter: @ignore_filter)
          .returns(@syncer)

        @syncer.expects(:start_threads)
        @syncer.expects(:shutdown)

        @syncer.expects(:download_theme!).with(delete: true)

        @ctx.expects(:done)

        @command.options.flags[:theme_id] = 1234
        @command.options.flags[:ignores] = ["config/*"]
        @command.call([], "pull")
      end

      def test_pull_asks_to_select
        CLI::UI::Prompt.expects(:ask).returns(@theme)
        @ctx.expects(:done)

        @syncer.expects(:download_theme!).with(delete: true)

        ShopifyCLI::Theme::Syncer.expects(:new)
          .with(@ctx, theme: @theme, query_filter: @query_filter, ignore_filter: @ignore_filter)
          .returns(@syncer)

        @syncer.expects(:start_threads)
        @syncer.expects(:shutdown)

        @command.call([], "pull")
      end
    end
  end
end
