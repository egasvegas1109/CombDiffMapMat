
    struct DiffuseMapData (
        diffuseMapName,
        materialID
    )

    fn getUniqueMaterialNamesAndIDs obj =
    (
        -- Создаем массив для хранения информации о DiffuseMap
        diffuseMapsData = #()

            convertToPoly obj
            -- Проверяем, является ли объект полигональным
            if (classof obj == Editable_Poly) then
            (
                -- Получаем количество граней на объекте
                numFaces = obj.numfaces
                
                -- Перебираем все грани на объекте
                for faceIndex = 1 to numFaces do
                (
                    -- Получаем ID материала для текущей грани
                    matID = polyOp.getFaceMatID obj faceIndex
                    
                    -- Получаем материал по его ID
                    material = obj.material[matID]
                    
                    -- Получаем DiffuseMap материала
                    diffuseMapName = ""
                    if isproperty material #diffuseMap do
                    (
                        diffuseMap = material.diffuseMap
                        if diffuseMap != undefined do
                        (
                            diffuseMapName = toLower(getFilenameFile(diffuseMap.fileName))
                        )
                    )

                    -- Проверяем, существует ли DiffuseMap
                    if diffuseMapName != "" then
                    (
                        -- Переменная, указывающая, найдена ли уже такая DiffuseMap
                        mapFound = false

                        -- Перебираем массив для проверки наличия DiffuseMap с таким же именем
                        for data in diffuseMapsData do
                        (
                            if (data.diffuseMapName == diffuseMapName) then
                            (
                                -- Если найдена DiffuseMap с таким же именем, устанавливаем флаг в true
                                mapFound = true
                                exit
                            )
                        )
                        
                        -- Если DiffuseMap с таким же именем не найдена, добавляем её в массив
                        if (mapFound == false) then
                        (
                            -- Создаем экземпляр структуры с данными о DiffuseMap и её ID
                            mapData = DiffuseMapData diffuseMapName matID
                            -- Добавляем данные о DiffuseMap в массив
                            append diffuseMapsData mapData
                        )
                    )
                )
            )
    return diffuseMapsData
    )

    fn setMaterialIDs obj diffuseNameId = (
        -- Перебираем все объекты в сцене
            -- Проверяем, является ли объект полигональным
            if (classof obj == Editable_Poly) then
            (
                -- Получаем количество граней на объекте
                numFaces = obj.numfaces
                
                -- Перебираем все грани на объекте
                for faceIndex = 1 to numFaces do
                (
                    -- Получаем ID материала для текущей грани
                    matID = polyOp.getFaceMatID obj faceIndex
                    
                    -- Получаем материал по его ID
                    material = obj.material[matID]
                    
                    -- Получаем DiffuseMap материала
                    diffuseMapName = ""
                    if isproperty material #diffuseMap do
                    (
                        diffuseMap = material.diffuseMap
                        if diffuseMap != undefined do
                        (
                            diffuseMapName = toLower(getFilenameFile(diffuseMap.fileName))
                        )
                    )
    
                    -- Проверяем, существует ли DiffuseMap
                    if diffuseMapName != "" then
                    (
                        -- Перебираем массив для проверки наличия DiffuseMap с таким же именем
                        for data in diffuseNameId do
                        (
                            if (data.diffuseMapName == diffuseMapName) then
                            (
                                polyOp.setFaceMatID obj faceIndex data.materialID
                            )
                        )
                    )
                )
            )
        return diffuseNameId
    )

    fn condenseMtlByID obj = (
        -- Принудительно конвертируем в Editable Mesh, если объект Editable Poly
        if classof obj == Editable_Poly do convertToMesh obj

        --If not Multimaterial--
        if classof obj.material != Multimaterial then return obj
        MaxID = obj.material.count
        IDAry = #()
        for i = 1 to obj.numfaces do (
            thisID = mod (getFaceMatID obj i) MaxID
            if thisID == 0 then thisID = MaxID
            if IDAry[thisID] == undefined then IDAry[thisID] = #()
            append IDAry[thisID] i
        )--end for i

        CondenseAry = #()
        for i = 1 to IDAry.count do
            if IDAry[i] != undefined then 	append CondenseAry i

        NewMtl = Multimaterial numsubs:CondenseAry.count
        for i = 1 to CondenseAry.count do (
            for j = 1 to IDAry[(CondenseAry[i])].count do setFaceMatID obj IDAry[(CondenseAry[i])][j] i
            NewMtl[i] = obj.material[(CondenseAry[i])]
        )
        obj.material = NewMtl

        convertToPoly obj
        return obj
    )
    --end fn CondenseMtlByID

    fn removeUnusedMaterials obj diffuseNameId =
    (
        if classof obj.material == MultiMaterial do
        (
            -- print ("Object:" + obj.name)
            -- print ("Materials before cleaning: " + obj.material.materialList.count as string)
            mmClean.fix #(obj.material) prompt:false
            -- print ("Materials after cleaning: " + obj.material.materialList.count as string)
        )
    )

rollout combiningMaterialsOnDiffuseMaps "CombDiffMapMat"(
    -- About
    button btn_about "About" width:92 height:23	 align:#right
    groupBox grB_1 "" pos:[0, 60] width:340 height:110
    label prgrs_mat "Cleaning of unused materials" pos:[15, 40]
    checkbox mt_4_cb checked:true pos:[160, 40]
    label label_clear "" pos:[0, 60]
    label current_obj_name ""
    label materials_count "Materials before: 0 | After: 0" pos:[15, 100] width:310
    progressbar current_obj_pb color:green 
    button btnApply "Combine materials"  width:150 align:#center

    on btn_about pressed do (
        rollout rol_meChecker_about "CombDiffMapMat - About" width:295   (

			label lbl1 "CombDiffMapMat 1.1"  height:17
			label lbl6 "Script features:" pos:[11,33] 
			label lbl7 "- Support for combining materials on multiple objects" pos:[13,53] 
			label lbl9 "- Removing unused materials" pos:[13,73] 
			label lbl11 "_____________________________"
			label lbl2 "\xa9 by " pos:[10,113] width:42 height:18
			HyperLink Goldfish "EgasVegas" pos:[37,113] width:60 height:18 address:"https://t.me/egasvegas" color:(color 10 147 225) hovercolor:(color 94 198 255) visitedcolor:(color 10 147 225)
            button btn_close "close" pos:[215,113] width:69 height:22
            on btn_close pressed do DestroyDialog  rol_meChecker_about 
		)
        createDialog rol_meChecker_about modal:true 
    )

    on btnApply pressed do (
        current_obj_pb.value = 0
        for obj in selection do
        (
            -- Сохраняем количество материалов до очистки
            local materials_before = if classof obj.material == MultiMaterial then obj.material.materialList.count else 1
            local diffuseNameId = getUniqueMaterialNamesAndIDs obj
            diffuseNameId = setMaterialIDs obj diffuseNameId

            if (mt_4_cb.checked == true) then
                removeUnusedMaterials obj diffuseNameId

            condenseMtlByID obj

            -- Сохраняем количество материалов после очистки
            local materials_after = if classof obj.material == MultiMaterial then obj.material.materialList.count else 1

            -- Обновляем текст с количеством материалов
            materials_count.text = "Materials before: " + materials_before as string + " | After: " + materials_after as string

            current_obj_name.text = obj.name
            current_obj_pb.value += 100/selection.count + 1
        )
        messageBox "Done!"
    )
)

-- Отображение интерфейса
createdialog combiningMaterialsOnDiffuseMaps 340 163


