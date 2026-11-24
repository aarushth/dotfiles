return {
	"danymat/neogen",
	dependencies = "nvim-treesitter/nvim-treesitter",
	config = function()
		local extractors = require("neogen.utilities.extractors")
		local nodes_utils = require("neogen.utilities.nodes")

		-- Same as neogen's default java function tree, minus the recursive
		-- `throw_statement` lookup inside the body, so @throws only comes
		-- from the `throws` clause on the declaration.
		local function_tree = {
			{
				retrieve = "first",
				node_type = "formal_parameters",
				subtree = {
					{
						retrieve = "all",
						node_type = "formal_parameter",
						subtree = {
							{ retrieve = "all", node_type = "identifier", extract = true },
						},
					},
				},
			},
			{
				retrieve = "all",
				node_type = "throws",
				subtree = {
					{ retrieve = "all", node_type = "type_identifier", extract = true, as = "throw_statement" },
				},
			},
			{
				retrieve = "first",
				node_type = "block|constructor_body",
				subtree = {
					{ retrieve = "first", node_type = "return_statement", extract = true },
					{
						retrieve = "first",
						node_type = "try_statement",
						subtree = {
							{
								retrieve = "first",
								node_type = "block",
								subtree = {
									{ retrieve = "first", node_type = "return_statement", extract = true },
								},
							},
						},
					},
				},
			},
		}

		local function extract(node)
			local nodes = nodes_utils:matching_nodes_from(node, function_tree)
			local res = extractors:extract_from_matched(nodes)
			return {
				parameters = res.identifier,
				throw_statement = res.throw_statement,
				return_statement = res.return_statement,
			}
		end

		require("neogen").setup({
			snippet_engine = "nvim",
			languages = {
				java = {
					template = {
						annotation_convention = "javadoc",
					},
					data = {
						func = {
							["method_declaration"] = { ["0"] = { extract = extract } },
							["constructor_declaration"] = {
								["0"] = {
									extract = function(node)
										local r = extract(node)
										r.return_statement = nil
										return r
									end,
								},
							},
						},
					},
				},
			},
		})
	end,
	keys = {
		{
			"<leader>wf",
			function()
				require("neogen").generate({ type = "func" })
			end,
			desc = "Generate Javadoc for function",
		},
		{
			"<leader>wc",
			function()
				require("neogen").generate({ type = "class" })
			end,
			desc = "Generate Javadoc for class",
		},
	},
}
