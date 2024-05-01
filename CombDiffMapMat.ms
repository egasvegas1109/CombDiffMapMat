-- Создаем структуру для хранения данных о DiffuseMap и её ID
struct DiffuseMapData (
    diffuseMapName,
    materialID
)

fn getUniqueMaterialNamesAndIDs =
(
    -- Создаем массив для хранения информации о DiffuseMap
    diffuseMapsData = #()

    -- Перебираем все объекты в сцене
    for obj in selection do
    (
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
    )
    
    -- Выводим результаты
    for data in diffuseMapsData do
    (
        format "%:%\n" data.diffuseMapName data.materialID
    )
)

fn setMaterialIDs diffuseMapsData = (
    -- Перебираем все объекты сцены
    for obj in selection do (
        convertToPoly obj
        -- Получаем количество материалов на объекте
        numMaterials = obj.material.numsubs
        
        -- Перебираем все материалы на объекте
        for i = 1 to numMaterials do (
            -- Получаем материал
            material = obj.material[i]
            
            -- Получаем количество граней на объекте
            numFaces = obj.numfaces
            
            -- Перебираем все грани на объекте
            for j = 1 to numFaces do (
                -- Получаем ID материала для текущей грани
                matID = polyop.getFaceMatID obj j
                
                -- Проверяем, совпадает ли ID материала с текущим индексом материала в цикле
                if (matID == i) then (
                    -- Получаем DiffuseMap материала
                    diffuseMap = material.diffuseMap
                    
                    -- Проверяем, существует ли DiffuseMap
                    if diffuseMap != undefined then (
                        -- Получаем имя DiffuseMap
                        diffuseMapName = toLower(getFilenameFile(diffuseMap.fileName))
                        
                        -- Переменная, указывающая, найдена ли уже такая DiffuseMap
                        mapFound = false
                        
                        -- Перебираем массив для проверки наличия DiffuseMap с таким же именем
                        for data in diffuseMapsData do (
                            if (data.diffuseMapName == diffuseMapName) then (
                                -- Если найдена DiffuseMap с таким же именем, устанавливаем флаг в true
                                mapFound = true
                                exit
                            )
                        )
                    )
                )
            )
        )
    )
        -- Выводим результаты
        for data in diffuseMapsData do (
            format "%:%\n" data.diffuseMapName data.materialID
        )
)
    getUniqueMaterialNamesAndIDs()



