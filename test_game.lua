describe("countNeighbors", function()
    it("should return 0 when there are no neighbors", function()
        local testGrid = {
            {false, false, false},
            {false, true, false},
            {false, false, false},
        }
        local neighbors = countNeighbors(2, 2, testGrid)
        assert.are.equals(0, neighbors)
    end)

    it("should return the correct number of neighbors", function()
        local testGrid = {
            {true, false, true},
            {false, true, false},
            {true, false, true},
        }
        local neighbors = countNeighbors(2, 2, testGrid)
        assert.are.equals(8, neighbors)
    end)

    it("should handle edge cases", function()
        local testGrid = {
            {false, false, true},
            {true, true, false},
            {false, true, false},
        }
        local neighbors = countNeighbors(1, 1, testGrid)
        assert.are.equals(3, neighbors)
    end)
end)
