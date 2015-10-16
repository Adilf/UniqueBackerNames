--this mod defines an interface with a couple of functions that should be used to 
--guarantee that backer name is unique for the relevant type of entities

local on_rename=script.generate_event_name();
--result is an event name: on_renamed
--on_rename is the event, which is raised after rename function is invoked, it contains fields {entity,old_name}
--which are self-explanatory, the purpose of this event is to let you update data structures in your mod

remote.add_interface("UniqueBackerNames",
{
    make_unique=function(entity)--this function appends the #number# to the backername of entity
    --if no explicit mischievous renaming takes place, this should be enough to guarantee
    --the uniqueness of the name
    --this function initializes the tracker for a specified type of entities if needed
    --if entity does not have the backer name of if the name already contains #number# fragment, function does nothing
        if not  string.find(entity.backer_name,"#%d+#") then
            global[entity.type]=(global[entity.type] or 0)+1--this is the counter that gets appended
            entity.backer_name=entity.backer_name.." #"..global[entity.type]..'#'
        end
    end,
    rename=function(entity,new_name)--this function changes the backer name whilst preserving the #number# appendage,
    --it also raises the event on_renamed if the evnty belongs to the type which is kept unique
    -- so that other mods could update their data structures
        if global[entity.type] then
            global[entity.type]=global[entity.type]+1 
            local old_name=entity.backer_name
            entity.backer_name=new_name.." #"..global[entity.type]..'#'
            game.raise_event(on_rename,{name=on_rename,tick=game.tick,old_name=old_name,entity=entity})
        else
            entity.backer_name=new_name
        end
    end,
    on_rename_event=function()
    --returns the name of on_rename event so it can be used in other mods
        return on_rename;
    end,
})
