function SavePos()
    if not LevelSystem then return end
    for k, ply in pairs(player.GetAll()) do
        local vply = GetVply(ply:Name())
        vply.PreviousPos2 = vply.PreviousPos1
        vply.PreviousPos1 = ply:GetPos()
    end
end