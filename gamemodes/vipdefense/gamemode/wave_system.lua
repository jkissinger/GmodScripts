function Debug()
    PrintTable( navmesh.GetAllNavAreas() )
    for k, v in pairs( player.GetAll() ) do
        print(v:GetName().." is at ")
        print(v:GetPos())
        navmesh.GetNearestNavArea(v:GetPos(), false, 10000, false, true, TEAM_ANY )
    end
end