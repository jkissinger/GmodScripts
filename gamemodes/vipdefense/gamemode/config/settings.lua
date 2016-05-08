function GM:PlayerSpawnSWEP( ply, class, info )
    if ply:IsAdmin() then
        Notify(ply, "Congrats, you're an admin!")
        return true
    else
        Notify(ply, "You must be an admin to spawn!")
        return false
    end
end