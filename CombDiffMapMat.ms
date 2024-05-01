(-- Создаем структуру для хранения данных о DiffuseMap и её ID
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
        
    )

    fn setMaterialIDs diffuseNameId = (
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
                        -- Перебираем массив для проверки наличия DiffuseMap с таким же именем
                        for data in diffuseMapsData do
                        (
                            if (data.diffuseMapName == diffuseMapName) then
                            (
                                polyOp.setFaceMatID obj faceIndex data.materialID
                            )
                        )
                    )
                )
            )
        )
    )

    local diffuseNameId = getUniqueMaterialNamesAndIDs()
    setMaterialIDs(diffuseNameId)
)



